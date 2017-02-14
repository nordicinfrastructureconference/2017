# Validate Script
function Get-File {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateScript({Test-Path $_})]
        [string] $Path
    )

    Get-Item $Path
}

Get-File C:\Users\ojk\Documents\NIC2017\Service1.log
#Get-File C:\Users\ojk\Documents\NIC2017\Service.log

# Validate Pattern
function Get-Email {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidatePattern('^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$')]
        [string] $Email
    )

    Write-Output $Email
}

Get-Email 'test@mail.com'
#Get-Email 'notan.email.com'