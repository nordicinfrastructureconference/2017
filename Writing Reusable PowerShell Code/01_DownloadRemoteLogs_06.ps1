# scripts can also use CmdletBinding
[CmdletBinding()]
param ()

$ErrorActionPreference = 'silentlyContinue'

$remoteLogs = @(
    'https://s3.eu-central-1.amazonaws.com/nic2017demologs01/Service1.log',
    'https://s3-eu-west-1.amazonaws.com/nic2017demologs02/Service2.log',
    'https://s3-eu-west-1.amazonaws.com/nic2017demologs03/Service3.log'
)

function Get-RemoteContent {
    [CmdletBinding()]
    param (
        [string]$Url
    )

    $log = Invoke-WebRequest -Uri $Url -Verbose:$false

    Write-Output $log.ToString()

    Write-Verbose 'This is a verbose message'
}

foreach ($remoteLog in $remoteLogs) {
    Get-RemoteContent $remoteLog -Verbose:$VerbosePreference
}