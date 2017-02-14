# allow empty string
$ErrorActionPreference = 'silentlyContinue'

function Test-Validation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $InputString
    )

    $InputString
    $InputString.Length
}

Test-Validation

#Test-Validation ''