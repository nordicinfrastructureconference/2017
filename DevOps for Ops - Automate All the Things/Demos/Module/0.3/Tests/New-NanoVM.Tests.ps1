Import-Module $PSScriptRoot\..\NIC.Serverdeployment.psd1 -Force

InModuleScope NIC.Serverdeployment {

Describe 'New-NanoVM' {

  Context "Desired parameters" {

    It 'Contains a VMName parameter' {

      (Get-Command New-NanoVM).Parameters.Keys -contains 'VMName' | Should Be $true

    }

    It 'Contains a VMMServer parameter' {

      (Get-Command New-NanoVM).Parameters.Keys -contains 'VMMServer' | Should Be $true

    }
    
  }

  Context 'Desired output' {

    Mock New-NanoVM {

      param (
        $VMName,
        $VMMServer = 'vmm-jr-01.rbk.ad'
      )

        [pscustomobject]@{

          VMName = $VMName
          VMHost = 'Hyper-V-01.test.local'
          IPAddress = '10.10.10.10'

      }
    }

        It 'Should produce a custom object' {

            $VM = New-NanoVM -VMName VM01
            
            $VM.GetType().Name | Should Be 'PSCustomObject'
            
        }

        It 'Should produce a object with 3 properties' {

        $VM = New-NanoVM -VMName VM01
        
        ($VM | Get-Member | Where-Object MemberType -eq 'NoteProperty').Count | Should Be 3
    
       }

        It 'The value supplied to the VMName parameter should be the same on the custom object outputted' {

        $VM = New-NanoVM -VMName VM01
        
        $VM.VMName | Should Be 'VM01'
    
       }
    

  }

 }

}