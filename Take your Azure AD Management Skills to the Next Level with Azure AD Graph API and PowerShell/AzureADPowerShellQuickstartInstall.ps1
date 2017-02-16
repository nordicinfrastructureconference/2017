# Azure AD v2 PowerShell Quickstart module install
# Azure AD has a GA version: AzureAD and Preview version: AzureADPreview

# Check available versions installed
Get-Module AzureAD -ListAvailable
Get-Module AzureADPreview -ListAvailable

# Install from PowerShell Gallery
Install-Module AzureAD
Install-Module AzureADPreview

# Update new versions from PS Gallery
Update-Module AzureAD
Update-Module AzureADPreview

# Check and uninstall old versions
$Latest = Get-InstalledModule ("AzureADPreview")
Get-InstalledModule ("AzureADPreview") -AllVersions | ? {$_.Version -ne $Latest.Version} | Uninstall-Module -WhatIf

# Check Commands, see also list of commands at: ref. https://docs.microsoft.com/en-us/powershell/azuread/v2/azureactivedirectory
Get-Command -Module AzureADPreview