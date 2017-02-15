# also support write to pipeline

function Test-Pipeline {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    Process {
        foreach ($item in $InputObject) {
            Write-Host $item.Count
            #Write-Output $item.Count
        }
    }
}

$services = Get-Service
#$services | Test-Pipeline
#Test-Pipeline $services

$test = $services | Test-Pipeline
$test.Count