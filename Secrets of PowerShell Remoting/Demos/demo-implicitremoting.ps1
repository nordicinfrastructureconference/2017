#demo implicit remoting in PowerShell

cls

#create a PowerShell session to a remote computer
$s = New-PSSession -ComputerName chi-hvr3

#import the module you want
Invoke-Command -scriptblock {import-module Hyper-V} -Session $s

invoke-command {get-command -Module Hyper-v} -session $s

#export the session
#this only needs to be done once
# help Export-PSSession

#or only export these commands
# $commands = "*-VM","*-VMSwitch"
Export-PSSession -Session $s -OutputModule myHyperV -Module Hyper-V -Force #-CommandName $commands

#remove the session
Remove-PSSession $s

#I now have a new module
get-module myHyperV -ListAvailable

#import it
import-module myHyperV

get-pssession
Get-Command -Module myHyperV

get-vmswitch
Get-VM

#not perfect due to serialization
Get-vm | Get-VMHardDiskDrive

Get-VMHardDiskDrive -VMname dmz* | Get-VHD

