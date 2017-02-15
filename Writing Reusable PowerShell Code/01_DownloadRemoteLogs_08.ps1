# Multiple parameters - parametersets - what's wrong?
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
        [Parameter(Position = 0, ParameterSetName = 'File')]
        [string]$Path,

        [Parameter(Position = 0, ParameterSetName = 'Url')]
        [string]$Url
    )

    if ($Url) {
        $log = Invoke-WebRequest -Uri $Url -Verbose:$false
    }
    elseif ($Path) {
        $log = Get-Content -Path $Path
    }

    Write-Output $log.ToString()

    Write-Verbose 'This is a verbose message'
}

foreach ($remoteLog in $remoteLogs) {
    Get-RemoteContent $remoteLog -Verbose:$VerbosePreference
}