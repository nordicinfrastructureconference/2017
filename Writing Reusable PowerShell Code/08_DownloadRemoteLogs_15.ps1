# creating a module
[CmdletBinding()]
param ()

$ErrorActionPreference = 'Continue' #default

Import-Module 'C:\users\ojk\Documents\NIC2017\WritingReusableCode\MyRemoteTools.psm1' -Force

$remoteLogs = @(
    'https://s3.eu-central-1.amazonaws.com/nic2017demologs01/Service1.log',
    'https://s3-eu-west-1.amazonaws.com/nic2017demologs02/Service2.log',
    'https://s3-eu-west-1.amazonaws.com/nic2017demologs03/Service3.log'
)

$result = $remoteLogs | Get-RemoteContent
$result