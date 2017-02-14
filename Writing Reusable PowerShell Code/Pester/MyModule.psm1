function Out-Upper {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $InputString
    )

    Process {
        foreach ($string in $InputString) {
            Write-Output ($string.ToUpper())
        }
    }
}

function Out-Lower {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $InputString
    )

    Process {
        foreach ($string in $InputString) {
            Write-Output ($string.ToUpper())
        }
    }
}

function Out-Capitalized {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $InputString
    )
    Process {
        foreach ($string in $InputString) {
        }
    }
}