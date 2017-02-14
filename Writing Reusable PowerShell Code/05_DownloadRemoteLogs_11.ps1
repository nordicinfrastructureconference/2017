# Let's add some basic error handling
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
        [string[]]$Url
    )

    Process {
        foreach ($item in $Url) {
            
            try {
                $log = Invoke-WebRequest -Uri $item -Verbose:$false -ErrorAction Stop

                Write-Output $log.ToString()
            }
            catch {
                Write-Warning $_
            }
        }
    }
}

$remoteLogs | Get-RemoteContent -Verbose
#Get-RemoteContent $remoteLogs