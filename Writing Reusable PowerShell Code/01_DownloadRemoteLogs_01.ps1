# original script

$ErrorActionPreference = 'silentlyContinue'

$log1 = Invoke-WebRequest 'https://s3.eu-central-1.amazonaws.com/nic2017demologs01/Service1.log'
$log2 = Invoke-WebRequest 'https://s3-eu-west-1.amazonaws.com/nic2017demologs02/Service2.log'
$log3 = Invoke-WebRequest 'https://s3-eu-west-1.amazonaws.com/nic2017demologs03/Service3.log'

$log1.ToString()
$log2.ToString()
$log3.ToString()