# "old" values in variable

$ErrorActionPreference = 'silentlyContinue'

$remoteLogs = @(
    'https://s3.eu-central-1.amazonaws.com/nic2017demologs01/Service1.log',
    'https://s3-eu-west-1.amazonaws.com/nic2017demologs02/Service2.log',
    'https://s3-eu-west-1.amazonaws.com/nic2017demologs03/Service3.log'
)

function Get-RemoteContent {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$Url
    )

    Process {
        foreach ($item in $Url) {

            #$log = [string]::Empty
            $log = Invoke-WebRequest -Uri $item

            Write-Output $log.ToString()
        }
    }
}

$remoteLogs | Get-RemoteContent