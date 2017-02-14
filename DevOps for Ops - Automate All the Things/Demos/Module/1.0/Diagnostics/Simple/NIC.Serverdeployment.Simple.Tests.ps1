Describe "Simple Validation of SQL Server used by SC VMM" {
    $ServerName = 'SQL-JR-02'
    $Session = New-PSSession -ComputerName $ServerName
    It "The SQL Server service should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name MSSQLSERVER}).status |
        Should be 'Running'
    }
    It "The SQL Server agent service should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name SQLSERVERAGENT}).status  |
        Should be 'Running'
    }
    It "Should be listening on port 1433" {
        Test-NetConnection -ComputerName $ServerName -Port 1433 -InformationLevel Quiet |
        Should be $true
    }
    It "Should be able to query information from the SQL Server" {
    (Invoke-Command -Session $Session {Invoke-Sqlcmd -Query "select name from sys.databases where name = 'master'" -ServerInstance $using:ServerName -Database master}).Name |
        Should be 'master'
    }
    Remove-PSSession -Session $Session
}

Describe "Simple Validation of SC VMM" {
    $ServerName = 'VMM-JR-01'
    $Session = New-PSSession -ComputerName $ServerName
    It "The VMM Server service should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name SCVMMService}).status |
        Should be 'Running'
    }
    It "The VMM agent service should be running" {
        (Invoke-Command -Session $Session {Get-Service -Name SCVMMAgent}).status  |
        Should be 'Running'
    }
    It "Should be listening on port 8100" {
        Test-NetConnection -ComputerName $ServerName -Port 8100 -InformationLevel Quiet |
        Should be $true
    }
    It "Should be able to query information from the VMM Server" {
    (Invoke-Command -Session $Session {Get-SCVMMServer -ComputerName localhost}).IsConnected |
        Should be $true
    }
    Remove-PSSession -Session $Session
}