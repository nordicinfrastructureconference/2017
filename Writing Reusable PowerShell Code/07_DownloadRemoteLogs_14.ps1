# Adding help
[CmdletBinding()]
param ()

$ErrorActionPreference = 'Continue' #default

$remoteLogs = @(
    'https://s3.eu-central-1.amazonaws.com/nic2017demologs01/Service1.log',
    'https://s3-eu-west-1.amazonaws.com/nic2017demologs02/Service2.log',
    'https://s3-eu-west-1.amazonaws.com/nic2017demologs03/Service3.log'
)

function Get-RemoteContent {
    <#
            .Synopsis
            Gets the content of a remote file.
            .Description
            This function gets the content of a remote file.
            .Example
            Get-RemoteContent $urlToRemoteFile
            .Example
            $urlToRemoteFile | Get-RemoteContent
            .Inputs
            System.Uri
            .Outputs
            PSObject
    #>
    [CmdletBinding()]
    param (
        # Url for remote file
        [Parameter(ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Uri[]]$Url
    )

    Process {
        foreach ($item in $Url) {
            
            try {
                if (Test-Connection -ComputerName $item.Host -Quiet -Count 1) {
                
                    Write-Verbose "Getting log from $($item.Host)"
                
                    $log = Invoke-WebRequest -Uri $item.ToString() -Verbose:$false -ErrorAction Stop

                    Write-Output ([PSCustomObject] [Ordered] @{
                            Url = $item.ToString()
                            LogContent = $log.ToString()
                            Host = $item.Host
                            LogFile = $item.Segments[-1]
                    })
                }
                else {
                    Write-Warning "Error connecting to '$($item.Host)'"
                }
                
            }
            catch {
                Write-Warning "Error getting log from '$($item.ToString())'"
            }
        }
    }
}

#$remoteLogs | Get-RemoteContent
$result = $remoteLogs | Get-RemoteContent
Get-Help Get-RemoteContent -Full