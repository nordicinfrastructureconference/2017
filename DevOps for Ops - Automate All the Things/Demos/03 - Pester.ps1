# Toggle regions: Ctrl + M

#region Demo setup
Write-Warning 'This is a demo script which should be run line by line or sections at a time, stopping script execution'

break

<#

    Author:      Jan Egil Ring & Øyvind Kallstad, Crayon AS
    Name:        03 - Pester.ps1
    Description: This demo script is part of the presentation 
                 DevOps for Ops - Automate All the Things!
                 
#>

<#

    What is Pester?

    Pester provides a framework for running unit tests to execute and validate PowerShell commands from within PowerShell. Pester consists of a simple set of functions that expose a testing domain-specific language (DSL) for isolating, running, evaluating and reporting the results of PowerShell commands.
    Pester tests can execute any command or script that is accessible to a Pester test file. This can include functions, cmdlets, modules and scripts. Pester can be run in ad-hoc style in a console or it can be integrated into the build scripts of a continuous integration (CI) system.
    Pester also contains a powerful set of mocking functions in which tests mimic any command functionality within the tested PowerShell code.

    https://github.com/pester/Pester
    http://www.powershellmagazine.com/2014/03/12/get-started-with-pester-powershell-unit-testing-framework/
    http://www.powershellmagazine.com/2014/03/27/testing-your-powershell-scripts-with-pester-assertions-and-more/
    https://github.com/PowerShell/PowerShell/blob/master/docs/testing-guidelines/WritingPesterTests.md
    https://github.com/pester/Pester/wiki

#>

Get-Module -ListAvailable -Name Pester

Find-Module -Name Pester

Get-Command -Module Pester

# This will run all tests inside of files named *.Tests.ps1 recursively from the current directory and print a report of all failing and passing test results to the console.
Invoke-Pester


# But first, let`s create a basic test-file
New-Item $env:temp\PesterDemo.tests.ps1

Set-Content -Path $env:temp\PesterDemo.tests.ps1 -Value @'

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

'@

psedit $env:temp\PesterDemo.tests.ps1

cd $env:temp
Invoke-Pester

Invoke-Pester -TestName Prerequisites

Invoke-Pester -TestName Properties

Invoke-Pester -PassThru

$Tests = Invoke-Pester -PassThru

$Tests.FailedCount

if ($Tests.FailedCount -eq 0) {

  #Do stuff

} else {

  throw "Pester tests failed, aborting execution..."

}

#Setup tests for our demo module NIC.ServerDeployment

cd 'D:\GitHub\Crayon.Demo.DevOps\Module\0.3\Tests'

psedit .\New-NanoVM.Tests.ps1

Invoke-Pester

<#

    Test Driven Development forces you think before you start scripting. If you are unable to write the tests, chances are you don’t fully understand the problem you are trying to solve.

#>


<#
    Operation-Validation-Framework

    A set of tools for executing validation of the operation of a system. It provides a way to organize and execute Pester tests which are written to validate operation (rather than limited feature tests)
    Modules which include a Diagnostics directory are inspected for Pester tests in either the "Simple" or "Comprehensive" directories.


    The module structure required is as follows:
    ModuleBase\
    Diagnostics\
      Simple simple tests are held in this location (e.g., ping, serviceendpoint checks)
      Comprehensive comprehensive scenario tests should be placed here


    https://github.com/PowerShell/Operation-Validation-Framework

#>

Install-Module -Name OperationValidation

Get-Command *operationvalidation*

$TestsFile ='D:\GitHub\Crayon.Demo.DevOps\Scripts\Operational Validation\HyperV.Tests.ps1'
$OutputFile = 'D:\temp\Report.xml'

psedit $TestsFile

Invoke-OperationValidation -testFilePath $TestsFile -IncludePesterOutput
Invoke-OperationValidation -testFilePath $TestsFile

$test = Invoke-Pester -Script $TestsFile -OutputFile $OutputFile -OutputFormat NUnitXml -PassThru

& D:\temp\ReportUnit.exe $OutputFile

Invoke-Item D:\temp\Report.html

Invoke-Item D:\temp\Environment-Report.html

# Many options for consuming the report, for example: Copy-Item to a webserver or Send-MailMessage to yourself with a daily operational validation report

<#

It`s not practical to deploy a new VM for every time a test runs, so how can we solve that? A dedicated test environment? Seems overkill for this kind of testing.

Mocking with Pester

With the set of Mocking functions that Pester exposes, one can:
  Mock the behavior of ANY powershell command.
  Verify that specific commands were (or were not) called.
  Verify the number of times a command was called with a set of specified parameters.

https://github.com/pester/Pester/wiki/Mocking-with-Pester

#>

Invoke-OperationValidation -ModuleName Crayon.Demo.DevOps -TestType Simple -IncludePesterOutput
Invoke-OperationValidation -testFilePath 'D:\GitHub\Crayon.Demo.DevOps\Module\Diagnostics\Simple\Crayon.Demo.DevOps.Simple.Tests.ps1' -IncludePesterOutput

#endregion