Import-Module .\MyModule.psm1

Describe 'MyModule Tests' {
    It 'Out-Upper Pipeline' {
        ("powershell" | Out-Upper) | Should BeExactly 'POWERSHELL'
    }

    It 'Out-Upper Parameter' {
        Out-Upper 'powershell' | Should BeExactly 'POWERSHELL'
    }

    It 'Out-Lower Pipeline' {
        ("POWERSHELL" | Out-Lower) | Should BeExactly 'powershell'
    }

    It 'Out-Lower Parameter' {
        Out-Lower 'POWERSHELL' | Should BeExactly 'powershell'
    }

    It 'Out-Capitalized Pipeline' {
        ("powershell" | Out-Capitalized) | Should BeExactly 'Powershell'
    }

    It 'Out-Capitalized Parameter' {
        (Out-Capitalized 'powershell') | Should BeExactly 'Powershell'
    }
}