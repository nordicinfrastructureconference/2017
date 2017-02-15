function Test-Pipeline {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    Write-Host $InputObject.Count
}

$services = Get-Service
$services | Test-Pipeline
Test-Pipeline $services
# what is happening here?