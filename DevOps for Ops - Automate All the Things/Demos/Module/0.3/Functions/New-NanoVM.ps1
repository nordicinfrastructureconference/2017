function New-NanoVM {

  param (
    $VMName,
    $VMMServer = 'vmm-jr-01.rbk.ad'
  )


  # ------------------------------------------------------------------------------
  # Create Virtual Machine Wizard Script
  # ------------------------------------------------------------------------------
  # Script generated on mandag 16. januar 2017 14.14.48 by Virtual Machine Manager
  # 
  # For additional help on cmdlet usage, type get-help <cmdlet name>
  # ------------------------------------------------------------------------------

  $JobGroup = (New-Guid).Guid
  $HardwareProfileName = 'Profile' + $JobGroup
  $TemporaryTemplateName = 'Temporary Template' + $JobGroup

  $null = New-SCVirtualScsiAdapter -VMMServer $VMMServer -JobGroup $JobGroup -AdapterID 7 -ShareVirtualScsiAdapter $false -ScsiControllerType DefaultTypeNoType 


  $null = New-SCVirtualDVDDrive -VMMServer $VMMServer -JobGroup $JobGroup -Bus 0 -LUN 1 

  $VMNetwork = Get-SCVMNetwork -VMMServer $VMMServer -Name "LAN" -ID "32381bef-07f5-4ea2-b107-e8ee90dd7c21"

  $null = New-SCVirtualNetworkAdapter -VMMServer $VMMServer -JobGroup $JobGroup -MACAddressType Dynamic -VLanEnabled $false -Synthetic -EnableVMNetworkOptimization $false -EnableMACAddressSpoofing $false -EnableGuestIPNetworkVirtualizationUpdates $false -IPv4AddressType Dynamic -IPv6AddressType Dynamic -VMNetwork $VMNetwork -DevicePropertiesAdapterNameMode Disabled 

  $CPUType = Get-SCCPUType -VMMServer $VMMServer | where {$_.Name -eq "3.60 GHz Xeon (2 MB L2 cache)"}

  $null = New-SCHardwareProfile -VMMServer $VMMServer -CPUType $CPUType -Name $HardwareProfileName -Description "Profile used to create a VM/Template" -CPUCount 2 -MemoryMB 1024 -DynamicMemoryEnabled $false -MemoryWeight 5000 -CPUExpectedUtilizationPercent 20 -DiskIops 0 -CPUMaximumPercent 100 -CPUReserve 0 -NumaIsolationRequired $false -NetworkUtilizationMbps 0 -CPURelativeWeight 100 -HighlyAvailable $false -DRProtectionRequired $false -SecureBootEnabled $true -SecureBootTemplate "MicrosoftWindows" -CPULimitFunctionality $false -CPULimitForMigration $false -CheckpointType Production -Generation 2 -JobGroup $JobGroup 



  $Template = Get-SCVMTemplate -VMMServer $VMMServer -ID "31d2e4b4-591e-4a91-a1ad-8c64310b0b9b" | where {$_.Name -eq "Nano Server - DevOps Demo"}
  $HardwareProfile = Get-SCHardwareProfile -VMMServer $VMMServer | where {$_.Name -eq $HardwareProfileName}

  $OperatingSystem = Get-SCOperatingSystem -VMMServer $VMMServer -ID "b808453f-f2b5-451f-894f-001c49db255a" | where {$_.Name -eq "Windows Server 2016 Standard"}

  $null = New-SCVMTemplate -Name $TemporaryTemplateName -Template $Template -HardwareProfile $HardwareProfile -JobGroup $JobGroup -ComputerName $VMName -TimeZone 110  -Workgroup "WORKGROUP" -AnswerFile $null -OperatingSystem $OperatingSystem 



  $template = Get-SCVMTemplate -All | where { $_.Name -eq $TemporaryTemplateName }
  $virtualMachineConfiguration = New-SCVMConfiguration -VMTemplate $template -Name $VMName

  $VMHost = Get-SCVMHost -ID "7114e348-9ffa-4469-bb00-d7482d25fca8"
  $null = Set-SCVMConfiguration -VMConfiguration $virtualMachineConfiguration -VMHost $vmHost
  $null = Update-SCVMConfiguration -VMConfiguration $virtualMachineConfiguration


  $AllNICConfigurations = Get-SCVirtualNetworkAdapterConfiguration -VMConfiguration $virtualMachineConfiguration
  $VHDConfiguration = Get-SCVirtualHardDiskConfiguration -VMConfiguration $virtualMachineConfiguration
  $null = Set-SCVirtualHardDiskConfiguration -VHDConfiguration $VHDConfiguration -PinSourceLocation $false -PinDestinationLocation $false -FileName ("$VMName" + "_disk_1") -StorageQoSPolicy $null -DeploymentOption "UseNetwork"

  
  $null = Update-SCVMConfiguration -VMConfiguration $virtualMachineConfiguration
  $null = New-SCVirtualMachine -Name $VMName -VMConfiguration $virtualMachineConfiguration -Description "" -BlockDynamicOptimization $false -StartVM -JobGroup $JobGroup -ReturnImmediately -StartAction "NeverAutoTurnOnVM" -StopAction "ShutdownGuestOS"

    do {
  
    $VMMJob = Get-SCJob | Where-Object ResultName -eq $VMName | Where-Object Name -eq 'Create virtual machine'
    
    Write-Host "Waiting for VM $VMName deployment to complete..." -ForegroundColor Yellow
    
    Start-Sleep 2
    
  } until (
  
    $VMMJob.Status -eq 'Completed'
    
  )
  
  $null = Get-SCHardwareProfile | Where-Object Name -eq $HardwareProfileName | Remove-SCHardwareProfile
  
  
      do {
  
    $VM = Hyper-V\Get-VM -CimSession $VMHost.Name -Name $VMName
    
    Write-Host "Waiting for VM IP Address..." -ForegroundColor Yellow
    
    Start-Sleep 2
    
  } until (
  
    $VM.NetworkAdapters[0].IPAddresses[0]
    
  )
  
  [pscustomobject]@{

    VMName = $VMName
    VMHost = $VMHost.Name
    IPAddress = $VM.NetworkAdapters[0].IPAddresses[0]

  }
  
 

}