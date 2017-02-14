function Test-Pipeline {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )
    Begin {}

    Process {
        Write-Host $InputObject.Count
    }
    
    End {}
}

$services = Get-Service
$services | Test-Pipeline
Test-Pipeline $services
