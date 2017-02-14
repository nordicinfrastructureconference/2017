# don't allow empty string

function Test-Validation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $InputString
    )

    $InputString
    $InputString.Length
}

#Test-Validation

Test-Validation ''