# Relative Paths in Modules
Import-Module 'C:\users\ojk\Documents\NIC2017\WritingReusableCode\DemoModule.psm1' -Force
Set-Location 'c:\Users'

Get-ContentRelativeToModule1

# Note PSScriptRoot variable only works in Modules
Get-ContentRelativeToModule2

