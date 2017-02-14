# make parameter mandatory
$ErrorActionPreference = 'continue'

function Test-Validation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $InputString
    )

    $InputString
    $InputString.Length
}

Test-Validation

# But what about this case?

#Test-Validation ''