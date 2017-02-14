 Param(
   [String]
   $VMName
 )


 Write-Output -InputObject "Runbook is executing on runbook worker $($env:ComputerName)"

 try
 {

   # Module autoloading will import the wrong module when AzureAutomationAuthoringToolkit is installed on hybrid runbook worker, thus we need to explicitly import the correct module
   Import-Module -Name Orchestrator.AssetManagement.Cmdlets -ErrorAction Stop
   Import-Module -Name D:\GitHub\Crayon.Demo.DevOps\Module\1.0\NIC.ServerDeployment.psd1 -ErrorAction Stop

 }

 catch {

   Write-Output "Failed to import prerequisite modules, aborting"
   break

 }

  Write-Output "Executing operational validation tests"

 $OperationsTest = Invoke-OperationValidation -testFilePath D:\GitHub\Crayon.Demo.DevOps\Module\1.0\Diagnostics\Simple
 
 if ($OperationsTest.Result -notcontains 'Failed') {
 
   Write-Output "All operational validation tests passed:"
   
   $OperationsTest | Select-Object Name,Result
 
 } else {
 
    Write-Output "All operational validation tests did not pass, aborting..."
   
   $OperationsTest | Select-Object Name,Result

   break
 
 }


 New-NanoVM -VMName $VMName

 Write-Output "Runbook completed"