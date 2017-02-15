# pipeline anti-patterns

# don't write to the host
function Test-Pipeline {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    Process {
        foreach ($item in $InputObject) {
            Write-Host $item.DisplayName
            Write-Output $item.Count
        }
    }
}

$services = Get-Service
$services | Test-Pipeline

$result = $services | Test-Pipeline
$result

# don't mix output types
function Test-Pipeline2 {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )
    Begin {
        $count = 0
    }
    
    Process {
        foreach ($item in $InputObject) {
            $count++
            if ($count -eq 5) {
                Write-Output ([PSCustomObject] @{
                        Name = $item.Name
                        Status = 'Fifth Element!'
                })
            }
            else {
                Write-Output ([PSCustomObject] @{
                        DisplayName = $item.DisplayName
                        StartType = $item.StartType
                        ServiceName = $item.ServiceName
                })
            }
        }
    }
}

$result = $services[0..8] | Test-Pipeline2
$result

$result[1]
$result[4]