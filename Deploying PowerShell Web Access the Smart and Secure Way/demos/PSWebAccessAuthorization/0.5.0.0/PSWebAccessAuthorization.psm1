#requires -version 5.0

#region enumerations

enum Ensure {
    Absent
    Present
}

<#
    There is a Microsoft.Management.PowerShellWebAccess.PswaDestinationType but
    it probably won't be available on the authoring computer so we'll define
    our own enumeration
#>

Enum DestinationType {
    Computer
    ComputerGroup
}

#same applies to [Microsoft.Management.PowerShellWebAccess.PswaUserType]
Enum UserType {
    User
    UserGroup
}

#endregion

[DscResource()]
class PwaAuthorizationRule {
    
#region properties

    <#
    rule names must be unique in your configuration.
    Wild cards are allowed if you want to remove mulitple rules,
    but if you do that do not create additional rules with the
    same name, especially if the LCM is set to autocorrect.
    
    #>
    [DscProperty(Key)]
    [string]$RuleName

    <#
      If ensure is set to absent all rules with the rule name will
      be deleted. 
    #>
    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    #defaults to current domain
    #cross domain support has not been tested
    [DscProperty()]
    [string]$Domain = $env:USERDOMAIN

    #Specifies the computer name or group to which this rule grants access.
    [DscProperty()]
    [string]$Destination

    #specify whether the destination is a computer name or group.
    [DscProperty()]
    [DestinationType]$DestinationType
    
    <#
    This can be a user name or a group. Multiple names are allowed
    but they must be the same type. Do NOT use the domain name
    If you enter a single name use the format @("username")
    #>
    [DscProperty()]
    [string[]]$Username

    [DscProperty()]
    [UserType]$UserType

    #This is the default remoting configuration
    [DscProperty()]
    [string]$Configuration = "Microsoft.PowerShell"

#endregion 

#region Methods
    [PwaAuthorizationRule] Get() {
        Write-Verbose "[CLASS] Invoking Get()"
        Write-Verbose "[CLASS] Getting authorization rule $($this.rulename)"
        #this could return multiple rules if multiple users or groups were specified
        $rule = Get-PswaAuthorizationRule -RuleName $this.RuleName -ErrorAction silentlycontinue
        
        #$rule | out-string | write-verbose
                
        if ($rule -and ($this.Ensure -eq [ensure]::Present)) {
            $result = @{
                RuleName = $this.RuleName
                Domain = $rule[0].user.split("\")[0]
                Username = $rule.user.foreach({$_.split("\")[1]}) -join ","
                UserType = ($rule.usertype | Get-Unique).ToString()
                Destination = $rule[0].Destination.split("\")[1]
                DestinationType = ($rule.DestinationType | Get-Unique).ToString()
                Configuration = $rule.configurationname | Get-Unique
                Ensure = "Present"
            }
            return $result
        }
        else { 
            Return @{
                RuleName = $this.RuleName
                Domain = $null
                Configuration = $null
                Ensure = "Absent"           
               }
           }

    } #Get

    [void] Set() {  
    #this resource cannot change existing rules
    
        Write-Verbose "[CLASS] Invoke SET()"

        if ($this.Ensure -eq [ensure]::Present) {
        $paramHash = @{
            RuleName = $this.RuleName
            ConfigurationName = $this.Configuration
            Force = $True
        }

        if ($this.DestinationType -eq [destinationtype]::ComputerGroup) {
            $paramHash.Add("ComputerGroupName","$($this.domain)\$($this.destination)")
        } else {
            $paramHash.Add("ComputerName","$($this.destination)")
        }

        if ($this.UserType -eq [usertype]::UserGroup) {
            $paramHash.Add("UserGroupName","$($this.domain)\$($this.username)")
        } else {
            #construct proper names. there might be multiple names
            $users = foreach ($item in $this.Username) {
                "$($this.Domain)\$item"
            }
            $paramHash.Add("UserName",$users)
        }

        Write-verbose "[CLASS] Adding new rule with these parameters"
        Write-verbose ($paramHash | Out-String)
       
        Add-PswaAuthorizationRule @paramHash 

        } else {
            Write-Verbose "[CLASS] Removing rule $($this.rulename)"
            Get-PswaAuthorizationRule -RuleName $this.RuleName |
            Remove-PswaAuthorizationRule  -Force
        }

    } #Set
 
    [bool] Test() {
        Write-Verbose "[CLASS] Invoking Test()"
        Write-Verbose "[CLASS] Testing for rule $($this.rulename)"
        $result = $false

        $rule = Get-PswaAuthorizationRule -RuleName $this.RuleName -ErrorAction silentlycontinue
        

        #$rule | out-string | write-verbose

        if ($this.Ensure -eq [ensure]::Present) {          
            
            $targetcomputer = "$($this.Domain)\$($this.destination)"
            #construct a string that accommodates multiple names
            $users = $this.Username | sort | foreach {
              "$($this.Domain)\$_"
            }

            $targetUser =   $users -join ","

            Write-Verbose "[CLASS] Target destination = $targetcomputer"
            Write-Verbose "[CLASS] Target user = $targetuser"
            
            If ( (($rule | sort user).user -join ",") -eq $targetUser -and $rule[0].Destination -eq $targetcomputer -and $rule[0].configurationName -eq $this.configuration) {
                Write-Verbose "[CLASS] Test for rule passed - nothing to configure"
                $result = $true
            } Else {
                Write-Verbose "[CLASS] Test for Rule failed - need to Set"
                $result = $False
            }
        } else {
            Write-Verbose "[CLASS] Testing for Absent"
            if ($rule.rulename) {
                #found the rule but shouldn't have
                $result = $False
            }
            else {
                #rule not expected or found
                $result = $True
            }
        }
        
        Return $result

    } #Test
#endregion
        
#There is no special constructor required

} #close class
            
            
