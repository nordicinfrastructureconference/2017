# using approved verbs (Get-Verb)

$ErrorActionPreference = 'silentlyContinue'

$remoteLogs = @(
    'https://s3.eu-central-1.amazonaws.com/nic2017demologs01/Service1.log',
    'https://s3-eu-west-1.amazonaws.com/nic2017demologs02/Service2.log',
    'https://s3-eu-west-1.amazonaws.com/nic2017demologs03/Service3.log'
)

function Get-RemoteContent ($Url) {
    $log = Invoke-WebRequest -Uri $Url
    $log.ToString()
}

foreach ($remoteLog in $remoteLogs) {
    Get-RemoteContent $remoteLog
}