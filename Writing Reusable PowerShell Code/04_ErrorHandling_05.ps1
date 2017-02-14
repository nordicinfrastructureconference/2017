# validate range

function Test-Validation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1,12)]
        [int] $Month
    )

    $Month
}

Test-Validation 2
Test-Validation 13

