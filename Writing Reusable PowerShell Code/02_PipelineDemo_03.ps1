function Test-Pipeline {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    Process {
        foreach ($item in $InputObject) {
            Write-Host $item.Count
        }
    }
}

$services = Get-Service
$services | Test-Pipeline
Test-Pipeline $services
