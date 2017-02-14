# validate set

function Test-Validation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Value1','Value2','Other')]
        [string] $InputString
    )

    $InputString
    $InputString.Length
}

Test-Validation 'Value1'
Test-Validation 'Value3'