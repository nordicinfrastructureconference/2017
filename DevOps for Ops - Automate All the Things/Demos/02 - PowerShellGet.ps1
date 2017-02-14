# Toggle regions: Ctrl + M

#region Demo setup
Write-Warning 'This is a demo script which should be run line by line or sections at a time, stopping script execution'

break

<#

    Author:      Jan Egil Ring & Øyvind Kallstad, Crayon AS
    Name:        02 - PowerShellGet.ps1
    Description: This demo script is part of the presentation 
                 DevOps for Ops - Automate All the Things!
                 
#>


#region Module basics

Get-Command *Module*

Get-Module

# List all modules available in $env:PSModulePath (typically C:\Program Files\WindowsPowerShell\Modules, C:\Windows\system32\WindowsPowerShell\v1.0\Modules & $env:USERPROFILE\Documents\WindowsPowerShell\Modules)
Get-Module -ListAvailable

# Creating your own module

# First, let`s clone the demo repository to local disk
git clone https://github.com/CrayonAS/NIC.ServerDeployment.git D:\GitHub\NIC.ServerDeployment

# Copy starting point
Copy-Item -Path D:\GitHub\Crayon.Demo.DevOps\Module\0.1\ -Destination D:\GitHub\NIC.ServerDeployment -Recurse -Container

dir D:\GitHub\NIC.ServerDeployment
tree D:\GitHub\NIC.ServerDeployment /F /A

$PSD1 = 'D:\GitHub\NIC.ServerDeployment\NIC.Serverdeployment.psd1'

$params = @{
  AliasesToExport = ''
  Author = 'Jan Egil Ring & Øyvind Kallstad'
  CmdletsToExport = ''
  Copyright = 'Crayon AS'
  CompanyName = 'Crayon AS'
  Description = 'Demo module for NIC 2017'
  Guid = (New-Guid).Guid
  FunctionsToExport = 'New-NanoVM','Connect-VMConsole','Invoke-OfflineDomainJoin'
  LicenseUri = 'https://github.com/CrayonAS/NIC.ServerDeployment/blob/master/LICENSE'
  ModuleVersion = '0.1'
  ReleaseNotes = 'Initial version'
  RootModule = 'NIC.ServerDeployment.psm1'
  Path = $PSD1
  PassThru = $true
  PowerShellVersion = '5.0'
  ProjectUri = 'https://github.com/CrayonAS/NIC.ServerDeployment'
  Tags = 'Tools'
  VariablesToExport = ''
}

New-ModuleManifest @params

psedit $PSD1

#endregion

#region PowerShellGet


Get-Module -Name PowerShellGet -ListAvailable
Get-Command -Module PowerShellGet

# Lists all available modules from all registered repositories
Find-Module

# www.powershellgallery.com is registered by default (untrusted)

Get-PSRepository

# Find and install modules
Find-Module -Name *FTP*
Find-Module -Name PSFTP | Install-Module
Install-Module -Name PSFTP
Find-Module -Name PS* | Out-GridView -OutputMode Multiple -Title 'Select modules to install' | Install-Module

# Register your own repositories. In this example we are using MyGet (www.myget.org) for hosting our internal gallery.
$CrayonRepositorySourceLocation = Get-Content -Path D:\GitHub\Crayon.repository.txt
$CrayonRepositoryPublishLocation = 'https://www.myget.org/F/crayon/api/v2/package'

# Register repository (once per user)
if(-not (Get-PSRepository -Name Crayon -ErrorAction SilentlyContinue))
{
    Register-PSRepository -Name Crayon -SourceLocation $CrayonRepositorySourceLocation -PublishLocation $CrayonRepositoryPublishLocation -InstallationPolicy Trusted
}

Find-Module -Repository Crayon

# Publish the initial version of our DevOps module
$NuGetApiKey = Get-Content -Path D:\GitHub\Crayon.repository.NuGetApiKey.txt
Publish-Module -Path D:\GitHub\NIC.ServerDeployment -Repository Crayon -NuGetApiKey $NuGetApiKey

# After publishing, the module is visible to everyone who has registered the Crayon repository
Find-Module -Repository Crayon

Install-Module -Name NIC.ServerDeployment -Repository Crayon

Get-Command -Module NIC.ServerDeployment

# As an operator, I want to use one of the commands to create a virtual machine running Nano Server
$VM = New-NanoVM -VMName NICNanoVM01

# Inspect module to look for errors
Invoke-Item (Get-Module -Name NIC.ServerDeployment).ModuleBase

# Submit issue on GitHub

# After the developer has fixed the issue and published a new version we can update the module
Update-Module -Name NIC.ServerDeployment -Verbose


# Bonus tip: Simply create an SMB file share-based repository in your own environment. It's a one-liner!
# Just make sure you set up a file share first where you have read and write permissions. Next, run this (we used \\server1\Gallery for our file share, so make sure you adjust this part):
Register-PSRepository -Name MyTeam -SourceLocation \\server1\Gallery -InstallationPolicy Trusted

#endregion