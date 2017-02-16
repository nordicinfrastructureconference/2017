#PSWA Demo

Return "This is a DEMO you fool!"

#region manually

#install the feature
$computername = "chi-test02"
get-windowsfeature -computername $computername | where installed
get-windowsfeature -computername $computername -Name *powershell*

#install the PSWA Feature
$addParams = @{
    Name = 'WindowsPowerShellWebAccess' 
    ComputerName = $computername 
    IncludeAllSubFeature = $True
    IncludeManagementTools = $True
}

Add-WindowsFeature @addParams

#what did we get
get-windowsfeature -computername $computername | where installed

#configure remotely
Enter-PSSession $computername
get-command -Noun *PSWA*
help Install-PswaWebApplication

Install-PswaWebApplication -UseTestCertificate

# open https://chi-test02/pswa and try to logon
start https://chi-test02/pswa
#add authorization rules
Get-PswaAuthorizationRule

exit

# help Add-PswaAuthorizationRule -full
#this must be run ON the server or the remote session needs CredSSP enabled

$cred = Get-Credential globomantics\jeff

$params = @{
    RuleName = "DomainAdminAccess"
    UserGroupName = "Globomantics\Domain Admins"
    ComputerGroupName = "globomantics\domain computers" 
    ConfigurationName = "Microsoft.PowerShell"
    Credential = $cred
}

Add-PswaAuthorizationRule @params 

#user must have remote access rights or a custom endpoint
# compmgmt.msc /computer:chi-sql01
# invoke-command { net localgroup administrators} -comp chi-sql01

$params = @{
    RuleName = "DBAAccess" 
    UserGroupName = "Globomantics\Chicago DBA" 
    ComputerName = "chi-sql01.globomantics.local"
    ConfigurationName = "Microsoft.PowerShell"
    credential = $cred
}

Add-PswaAuthorizationRule @params 

Get-PswaAuthorizationRule

#test on the server
# Test-PswaAuthorizationRule -ComputerName chi-sql01.globomantics.local -UserName globomantics\ajabra -credential $cred
# Test-PswaAuthorizationRule -ComputerName chi-dc04.globomantics.local -UserName globomantics\ajabra -credential $cred

#test in browser
start https://chi-test02.globomantics.local/pswa

<# reset demo
icm {
Uninstall-PswaWebApplication
Remove-WindowsFeature -Name WindowsPowerShellWebAccess,Web-Server
Restart-computer -Force
} -computername $computername
#>

#endregion

#region using DSC

#Create an SSL cert
$cred = Get-Credential globomantics\jeff

<# might neeed CredSSP
 Enter-PSSession chi-test03
 Enable-WSManCredSSP -Role Client -DelegateComputer chi-dc04* -force
 Get-WSManCredSSP
 cd WSMan:\localhost\service\auth
 exit
#>

#create an SSL cert (already done in my demo)
Invoke-Command {
$params = @{
    Template = "WebServer" 
    DnsName = "pswa.globomantics.local","chi-test03.globomantics.local" 
    SubjectName = "CN=PSWA.globomantics.local"
    Url = 'https://chi-dc04.globomantics.local/ADPolicyProvider_CEP_Kerberos/service.svc/cep'
    CertStoreLocation = "Cert:\LocalMachine\My"
}
Get-Certificate @params
} -computername chi-test03 -Credential $cred -Authentication Credssp

icm {dir Cert:\LocalMachine\my | Select Thumbprint,Subject,Enhance*} -computer chi-test03

<# add DNS entries
# This has already been done in my domain

$dnsParams = @{
    ComputerName = 'chi-dc04'
    name = 'PSWA'
    ZoneName = 'globomantics.local' 
    IPv4Address = '172.16.30.20'
}

Add-DnsServerResourceRecordA @dnsParams 
#>

Get-DnsServerResourceRecord -Name PSWA -ZoneName globomantics.local -ComputerName chi-dc04

#test
Resolve-DnsName chi-test03.globomantics.local
Resolve-DnsName pswa.globomantics.local

#check LCM
Get-DscLocalConfigurationManager -CimSession CHI-TEST03

#create an LCM meta config if necessary
[DSCLocalConfigurationManager()]
Configuration LCMPUSH {	

Param([string]$Computername)

	Node $Computername
	{
		Settings
		{
			AllowModuleOverwrite = $True
            ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Push'
            ActionAfterReboot = 'ContinueConfiguration'
            DebugMode = 'All'	
		}
	}
}

LCMPUSH -Computername chi-test03 -OutputPath c:\dsc\lcmpush
Set-DscLocalConfigurationManager -Path C:\dsc\lcmpush -Verbose

#DSC Configuration uses several custom resources
#Find-module PSWebAccessAuthorization
psedit .\PSWebAccessAuthorization\0.5.0.0\PSWebAccessAuthorization.psm1
psedit .\PWAConfig.ps1

# Get the certificate Thumbprint
$cert = Invoke-Command -Computername CHI-TEST03 { Get-Childitem Cert:\LocalMachine\My | 
Where-Object {$_.Subject -like "*PSWA*"} | Select-Object -ExpandProperty ThumbPrint}

# Create the config
$params = @{
    NodeName =  'CHI-TEST03'
    PSWASiteName = 'PSWA'
    PSWAppPoolName = 'PSWA_Pool'
    CertThumbPrint = $cert
    OutputPath = 'c:\DSC\PSWA'
}

#check parameters
$params

#create the config
PSWA @params

# psedit C:\dsc\PSWA\CHI-TEST03.mof

#push the resources or have the server install from the gallery
$s = new-pssession chi-test03
$needed = "xWebAdministration","cNTFSAccessControl","PSWebAccessAuthorization"

Split-Path (get-module $needed -ListAvailable ).ModuleBase | 
Copy-Item -recurse -Destination 'C:\Program Files\WindowsPowerShell\Modules' -force -Tosession $S

icm { get-module $using:needed -ListAvailable } -session $s
icm { get-dscresource xwebsite,pwaAuthorizationRule,cntfsPermissionEntry} -session $s

# Push the config
cls
Start-DscConfiguration -ComputerName CHI-TEST03 -Path C:\DSC\PSWA -Wait -Verbose -force

#verify
get-windowsfeature -ComputerName chi-test03 | where installed

#reboot for good measure
#restart-computer chi-test03.globomantics.local -Force -Wait -For WinRM

<#
manually add authorization rules
invoke-command -scriptblock { 
 Add-PswaAuthorizationRule -RuleName "DomainAdminAccess" -UserGroupName "Globomantics\Domain Admins" -ComputerGroupName "globomantics\domain computers" -ConfigurationName Microsoft.PowerShell -credential $using:cred
 Add-PswaAuthorizationRule -RuleName "DBAAccess" -UserGroupName "Globomantics\Chicago DBA" -ComputerName chi-sql01.globomantics.local -ConfigurationName Microsoft.PowerShell -credential $using:cred
 Add-PswaAuthorizationRule -RuleName "PWADemo" -UserName "Globomantics\adeco" -ComputerGroupName "globomantics\pwa_computers" -ConfigurationName Microsoft.PowerShell -credential $using:cred
} -session $s
#>

invoke-command { get-pswaauthorizationRule } -session $s -HideComputerName | Out-GridView

invoke-command {
Test-PswaAuthorizationRule -ComputerName chi-sql01.globomantics.local -UserName globomantics\ajabra -credential globomantics\ajabra
} -session $s

<#
#verify a potential access problem
#app pool needs RX permission on the rules xml file

 enter-pssession $s
 icacls.exe C:\Windows\web\PowerShellWebAccess\data\AuthorizationRules.xml
 icacls.exe C:\Windows\web\PowerShellWebAccess\data\AuthorizationRules.xml /grant ('"' + "IIS AppPool\PSWA_Pool" + '":RX')
 exit

#>

# Get-ADGroupMember pwa_computers | select name
#Test
start https://pswa.globomantics.local/pswa

#endregion

#region Troubleshooting
enter-pssession chi-test03
Get-WinEvent -ListLog *powershell* #-ComputerName chi-test03

get-Winevent -LogName Microsoft-Windows-PowerShellWebAccess/Operational -MaxEvents 5 | 
format-table TimeCreated,Message -wrap

Get-WinEvent -ListLog *http*,*web*,*iis*
Get-WinEvent -LogName Microsoft-Windows-HttpService/log -MaxEvents 5

#endregion

#region Undo demo

enter-pssession chi-test03

Remove-DscConfigurationDocument -Stage Current -Force
Get-PswaAuthorizationRule | Remove-PswaAuthorizationRule
#dir Cert:\LocalMachine\my | where {$_.Subject -match "PSWA|PowershellWebAccess"} | del
Uninstall-PswaWebApplication
remove-windowsfeature WindowsPowerShellWebAccess,Web-Server
exit

restart-computer -force -Wait -For WinRM -ComputerName chi-test03
#verify
icm {dir C:\Windows\web\PowerShellWebAccess } -computername chi-test03

#endregion

#region Bonus: DMZ workgroup

#DMZ server networking and firewall configurations could get complicated

$computer = "dmz-web"
$cred = Get-Credential "dmz-web\administrator"

get-windowsfeature -ComputerName $computer -Credential $cred

#setup as POC
#install the PSWA Feature
$addParams = @{
    Name = 'WindowsPowerShellWebAccess' 
    ComputerName = $computer
    IncludeAllSubFeature = $True
    IncludeManagementTools = $True
    credential = $Cred
}

Add-WindowsFeature @addParams

$s = New-PSSession -ComputerName $computer -Credential $cred

Invoke-Command -scriptblock {Install-PswaWebApplication -UseTestCertificate} -session $s

Invoke-Command -ScriptBlock {
$params = @{
    RuleName = "LocalAccess"
    UserName = "DMZ-Web\Administrator"
    ComputerName = "DMZ-Web" 
    ConfigurationName = "Microsoft.PowerShell"
    Force = $True
}

Add-PswaAuthorizationRule @params


} -session $s

#this won't work unless the DMZ has a way to resolve domain names to SIDS
Invoke-Command -ScriptBlock {
$params = @{
    RuleName = "DomainAdminAccess"
    UserGroupName = "Globomantics\Domain Admins"
    ComputerGroupName = "globomantics\domain computers" 
    ConfigurationName = "Microsoft.PowerShell"
    Credential = (Get-Credential globomantics\jeff)
    Force = $True
}

Add-PswaAuthorizationRule @params
} -session $s

#one workaround is to provide local account for access
#and then you specify domain credentials for server itself

Invoke-Command -ScriptBlock {
$params = @{
    RuleName = "CHI-P50"
    UserName = "DMZ-Web\PWA"  #<--local account I created
    ComputerName = "CHI-P50" 
    ConfigurationName = "Microsoft.PowerShell"
    Force = $True
}

Add-PswaAuthorizationRule @params
} -session $s


<#
You *might* be able to manually modify the Authorization rule xml file

<Rules>
  <Rule>
    <Id>0</Id>
    <Name>LocalAccess</Name>
    <UserCanonicalForm>S-1-5-21-2060140782-413147150-3867729616-500</UserCanonicalForm>
    <UserType>User</UserType>
    <DestinationCanonicalForm>DMZ-Web</DestinationCanonicalForm>
    <DestinationType>Computer</DestinationType>
    <ConfigurationName>microsoft.powershell</ConfigurationName>
    <IsUserGroupLocal>true</IsUserGroupLocal>
    <IsComputerGroupLocal>false</IsComputerGroupLocal>
    <IsCanonicalDestinationSid>false</IsCanonicalDestinationSid>
  </Rule>
</Rules>


[xml]$r = Get-Content .\AuthorizationRules.xml
$n = $r.rules.rule | Select -last 1

#next number
$hash = [ordered]@{
    Id = ($n.Id -as [int])+1
    Name = "DomainAccess"
    UserCanonicalForm = (Get-ADgroup "domain admins").Sid.Value
    UserType = "UserGroup"
    DestinationCanonicalForm = (Get-ADgroup "domain computers").sid.Value
    DestinationType = "ComputerGroup"
    ConfigurationName = "microsoft.powershell"
    IsUserGroupLocal = "false"
    IsComputerGroupLocal = "false" 
    IsCanonicalDestinationSid = "true"
}

$new = $r.CreateNode("element","Rule",$null)

foreach ($item in $hash.keys) {
 $e = $r.CreateElement($item)
 $e.InnerText = $hash.item($item)
 $new.AppendChild($e)
}

$r.rules.AppendChild($new) | Out-Null
$file = Convert-path .\AuthorizationRules.xml
$r.Save($file)
copy $file -Destination c:\windows\web\PowerShellWebAccess\Data -ToSession $s
#>

invoke-command { get-pswaauthorizationrule} -session $s

#Try it
start https://dmz-web/pswa

#endregion