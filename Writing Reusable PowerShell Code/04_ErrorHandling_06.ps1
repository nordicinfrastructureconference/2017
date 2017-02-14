# validate types

function Div {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateRange(1, 99)]
        [int16]$Dividend,

        [Parameter(Position = 1)]
        [ValidateRange(1, [int16]::MaxValue)]
        [int16]$Divisor = 2
    )

    $Dividend / $Divisor
}

Div 100

# But what about these cases?
#Div 40000
#Div 100 0


# Int16  goes from -32768 to 32767
# UInt16 goes from 0 to 65535
# [int16]::MinValue, [int16]::MaxValue