#requires -version 5.0

#This version uses the default website

configuration PSWA {
    param
    (
        # Target nodes to apply the configuration
        [Parameter(Mandatory = $true)]
        [string[]]$NodeName,

        # Name of the website to create
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$PSWASiteName,

        # Name of the website to create
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$PSWAppPoolName,

        # Certificate ThumbPrint
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$CertThumbprint,
        [string]$DomainDN = "Globomantics.local"        
    )

    # Import the module that defines custom resources
    Import-DscResource -Module PSDesiredStateConfiguration,
    @{ModuleName = 'xWebAdministration';RequiredVersion = '1.16.0.0'},
    @{ModuleName = 'cNTFSAccessControl';RequiredVersion = '1.3.0'},
    @{ModuleName = 'PSWebAccessAuthorization';RequiredVersion = '0.5.0.0'}
       
    Node $NodeName    {
        
        # Install the PSWA feature
        WindowsFeature PSWA
        {
            Ensure          = "Present"
            Name            = "WindowsPowerShellWebAccess"
        }
             
        # Create the new Application Pool    
        xWebAppPool PSWAPool 
        {
            Ensure                = "Present"
            Name                  = $PSWAppPoolName
            autoStart             = $True
            managedRuntimeVersion = "v4.0"
            managedPipelineMode   = "Integrated"
            startMode             = "AlwaysRunning"
            identityType          = "ApplicationPoolIdentity"
            restartSchedule       = @("18:30:00","05:00:00")
            DependsOn             = @('[WindowsFeature]PSWA') 

        }

        # Set permission for the app pool
        # How I used to do it in scripts
        # icacls.exe C:\Windows\web\PowerShellWebAccess\data\AuthorizationRules.xml /grant:r ('"' + "IIS AppPool\PSWA_Pool" + '":R')
        
        <#
        cNTFSPermission AppPoolPermission {
       
           Ensure          = "Present"
           Account         = "users"
           Access          = "Allow"
           Path            = "C:\Windows\web\PowerShellWebAccess\data\AuthorizationRules.xml"
           Rights          = 'ReadAndExecute'
           NoInherit       = $true
           DependsOn       = '[xWebAppPool]PSWAPool'
       }    
       #>

         cNtfsPermissionEntry AppPoolPermission {
            Path = "C:\Windows\web\PowerShellWebAccess\data\AuthorizationRules.xml"
            Principal = "IIS AppPool\$PSWAppPoolName"
            AccessControlInformation = @(
                cNtfsAccessControlInformation
                {
                    AccessControlType = 'Allow'
                    FileSystemRights = 'ReadAndExecute'
                    Inheritance = 'None'
                    #NoPropagateInherit = $True
                }
           )
            DependsOn = '[xWebAppPool]PSWAPool'
            Ensure = 'Present'
            ItemType = 'File'
            
        }   
        
        #Configure the web site with SSL
        xWebsite Default {
            Name = 'Default Web Site'
            Ensure = 'Present'
            State = 'Started'
            AuthenticationInfo =  MSFT_xWebAuthenticationInformation {
                Windows = $True
                Anonymous = $True
                Basic = $False
            }
            BindingInfo =  MSFT_xWebBindingInformation  
                             { 
                               Protocol              = "HTTPS" 
                               Port                  = 443 
                               Hostname              = "$PSWASiteName.$DomainDN"
                               CertificateThumbprint = "$certThumbprint"
                               CertificateStoreName  = "MY" 
                               SslFlags              = 0
                             } 
          DependsOn = '[WindowsFeature]PSWA'
        }

        #configure the access rules
        #passing via configurationdata would be a good idea
        pwaAuthorizationRule DBA {
            RuleName = 'DBA_Access'
            Ensure = 'Present'
            Destination = 'chi-sql01.globomantics.local'
            DestinationType = 'Computer'
            Username = "Chicago DBA"
            UserType = 'UserGroup'
            dependson = '[WindowsFeature]PSWA'
        }

        pwaAuthorizationRule DomainAdmin {
            RuleName = 'DA_Access'
            Ensure = 'Present'
            Destination = 'domain computers'
            DestinationType = 'ComputerGroup'
            Username = 'domain admins'
            UserType = 'UserGroup'
            dependson = '[WindowsFeature]PSWA'
        }

        pwaAuthorizationRule PWADemo {
            RuleName = 'PWADemo'
            Ensure = 'Present'
            Destination = 'pwa_computers'
            DestinationType = 'ComputerGroup'
            Username = 'adeco'
            UserType = 'User'
            Configuration = 'microsoft.powershell'
            dependson = '[WindowsFeature]PSWA'
        }

        xWebApplication PSWA {
            Website = 'Default Web Site' #$PSWASiteName
            Name = $PSWASiteName
            WebAppPool = $PSWAppPoolName 
            PhysicalPath = "C:\Windows\web\PowerShellWebAccess\wwwroot"
            Ensure = 'Present'
            SslFlags = 'ssl'
            ServiceAutoStartEnabled = $True
            AuthenticationInfo =  MSFT_xWebApplicationAuthenticationInformation {
                Windows = $True
                Anonymous = $True
                Basic = $False
            }               
            DependsOn = '[xWebAppPool]PSWAPool','[xWebSite]Default'
        }

        <# 
          GUI Remote Management of IIS requires the following: - 
          people always forget this until too late
        #>

        WindowsFeature Management {
            Name = 'Web-Mgmt-Service'
            Ensure = 'Present'
        }

        Registry RemoteManagement { 
            # Can set other custom settings inside this reg key
            Key = 'HKLM:\SOFTWARE\Microsoft\WebManagement\Server'
            ValueName = 'EnableRemoteManagement'
            ValueType = 'Dword'
            ValueData = '1'
            DependsOn = @('[xWebAppPool]PSWAPool','[WindowsFeature]Management')
       }

       Service StartWMSVC {
            Name = 'WMSVC'
            StartupType = 'Automatic'
            State = 'Running'
            DependsOn = '[Registry]RemoteManagement'
       }

    }
}

<#
# Get the certificate Thumbprint
$cert = Invoke-Command -Computername CHI-TEST03 { Get-Childitem Cert:\LocalMachine\My | Where-Object {$_.Subject -like "*PSWA*"} | Select-Object -ExpandProperty ThumbPrint}

# Create the config
PSWA -NodeName CHI-TEST01 -PSWASiteName PSWA -PSWAppPoolName PSWA_Pool -CertThumbPrint $cert -OutputPath c:\DSC\PSWA

# Push the config
Start-DscConfiguration -ComputerName CHI-TEST03 -Path C:\DSC\PSWA -Wait -Verbose -force

#>