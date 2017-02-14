# creating functions

$ErrorActionPreference = 'silentlyContinue'

$remoteLogs = @(
    'https://s3.eu-central-1.amazonaws.com/nic2017demologs01/Service1.log',
    'https://s3-eu-west-1.amazonaws.com/nic2017demologs02/Service2.log',
    'https://s3-eu-west-1.amazonaws.com/nic2017demologs03/Service3.log'
)

function Download-Log ($Url) {
    $log = Invoke-WebRequest -Uri $Url
    $log.ToString()
}

foreach ($remoteLog in $remoteLogs) {
    Download-Log $remoteLog
}