Describe "Prerequisites" {

  It  'PowerShell version should be at least 4.0' {
  
    $PSVersionTable.PSVersion.Major | Should BeGreaterThan 4
  
  }

}

Describe "Properties" {

  It  'Get-Service should contain a Status property' {
  
    (Get-Service | Get-Member).Name -contains 'Status' | Should Be $true
  
  }

}