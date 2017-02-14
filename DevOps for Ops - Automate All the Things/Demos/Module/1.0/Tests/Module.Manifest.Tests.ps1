param
(
	[Parameter(Mandatory = $false)]
	[ValidateScript({ Get-Module -ListAvailable -Name $_ })]
	[string]
	$ModuleName = 'NIC.Serverdeployment',
	
	[Parameter(Mandatory = $false)]
	[System.Version]
	$RequiredVersion
)

# If no version specified, use latest
if (-not $RequiredVersion)
{
	$RequiredVersion = (Get-Module $ModuleName -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1).Version
}

# Remove all versions of the module from the session. Pester can't handle multiple versions.
Get-Module $ModuleName | Remove-Module

# Find the Manifest file
$ManifestFile = "$(Split-path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))\$ModuleName.psd1"

# Import the module and store the information about the module
$ModuleInformation = Import-Module -Name $ManifestFile -PassThru

# Get the functions present in the Manifest
$ExportedFunctions = $ModuleInformation.ExportedFunctions.Values.name

# Get the functions present in the Public folder
$PS1Functions = Get-ChildItem -path "$(Split-path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))\Functions\*.ps1"

Describe "$ModuleName Module - Testing Manifest File (.psd1)"{
    Context 'Manifest'{
        It 'Should contains RootModule' {
            $ModuleInformation.RootModule | Should not BeNullOrEmpty
        }
        It 'Should contains Author' {
            $ModuleInformation.Author | Should not BeNullOrEmpty
        }
        It 'Should contains Company Name' {
            $ModuleInformation.CompanyName | Should not BeNullOrEmpty
        }
        It 'Should contains Description' {
            $ModuleInformation.Description | Should not BeNullOrEmpty
        }
        It 'Should contains Copyright' {
            $ModuleInformation.Copyright | Should not BeNullOrEmpty
        }

        if ($PSVersionTable.PSVersion.Major -ge 5) {

        It 'Should contains License' {
            $ModuleInformation.LicenseURI | Should not BeNullOrEmpty
        }
        It 'Should contains a Project Link' {
            $ModuleInformation.ProjectURI | Should not BeNullOrEmpty
        }
        It 'Should contains a Tags (For the PSGallery)' {
            $ModuleInformation.Tags.count | Should not BeNullOrEmpty
        }

        }
        
        It 'Compare the count of Function Exported and the PS1 files found' {
            $ExportedFunctions.count -eq $PS1Functions.count |
            Should BeGreaterthan 0
        }
        It 'Compare the missing function' {
            if (-not ($ExportedFunctions.count -eq $PS1Functions.count))
            {
                $Compare = Compare-Object -ReferenceObject $ExportedFunctions -DifferenceObject $PS1Functions.basename
                $Compare.inputobject -join ',' | Should BeNullOrEmpty
            }
        }
    }
}