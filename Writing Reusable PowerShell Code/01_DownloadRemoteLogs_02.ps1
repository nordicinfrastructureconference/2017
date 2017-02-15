# identify repeating code

$ErrorActionPreference = 'silentlyContinue'

#region Getting logs OLD

    <#
    $log1 = Invoke-WebRequest 'https://s3.eu-central-1.amazonaws.com/nic2017demologs01/Service1.log'
    $log2 = Invoke-WebRequest 'https://s3-eu-west-1.amazonaws.com/nic2017demologs02/Service2.log'
    $log3 = Invoke-WebRequest 'https://s3-eu-west-1.amazonaws.com/nic2017demologs03/Service3.log'
    #>

#endregion

#region Getting logs NEW

    $remoteLogs = @(
        'https://s3.eu-central-1.amazonaws.com/nic2017demologs01/Service1.log',
        'https://s3-eu-west-1.amazonaws.com/nic2017demologs02/Service2.log',
        'https://s3-eu-west-1.amazonaws.com/nic2017demologs03/Service3.log'
    )

    $downloadedLogs = @()

    foreach ($remoteLog in $remoteLogs) {
        $downloadedLogs += Invoke-WebRequest -Uri $remoteLog
    }

#endregion

#region Getting Status OLD

    <#
    $log1.ToString()
    $log2.ToString()
    $log3.ToString()
    #>

#endregion

#region Getting Status NEW

    foreach ($downloadedLog in $downloadedLogs) {
        $downloadedLog.ToString()
    }

#endregion