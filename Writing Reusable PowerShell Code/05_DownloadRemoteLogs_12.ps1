# Validation by type + verbose messages
[CmdletBinding()]
param ()

$ErrorActionPreference = 'Continue' #default

$remoteLogs = @(
    'https://s3.eu-central-1.amazonaws.com/nic2017demologs01/Service1.log',
    'https://s3-eu-west-1.amazonaws.com/nic2017demologs02/Service2.log',
    'https://s3-eu-west-1.amazonaws.com/nic2017demologs03/Service3.log'
)

function Get-RemoteContent {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Uri[]]$Url
    )

    Process {
        foreach ($item in $Url) {
            
            try {
                Write-Verbose "Getting log from $($item.Host)"
                
                $log = Invoke-WebRequest -Uri $item.ToString() -Verbose:$false -ErrorAction Stop

                Write-Output $log.ToString()
            }
            catch {
                Write-Warning "Error getting log from '$($item.ToString())'"
            }
        }
    }
}

$remoteLogs | Get-RemoteContent -Verbose
#Get-RemoteContent $remoteLogs