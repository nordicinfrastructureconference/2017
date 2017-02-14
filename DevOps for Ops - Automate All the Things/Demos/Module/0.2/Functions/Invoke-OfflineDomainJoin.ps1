function Invoke-OfflineDomainJoin {

  param (
    $ComputerName,
    $Credential,
    $DomainName = $env:USERDOMAIN
  )

  $DomainBlobFilePath = Join-Path -Path $env:temp -ChildPath ($ComputerName + '.djoin')
  Djoin.exe /Provision /Domain $DomainName /Machine $ComputerName /Savefile $DomainBlobFilePath

  $Session = New-PSSession -ComputerName $ComputerName -Credential $Credential -Authentication Negotiate
  
  Copy-Item -ToSession $Session -Path $DomainBlobFilePath -Destination C:\

  Invoke-Command -Session $Session -ScriptBlock {dir c:\}

  $LocalDomainBlobFilePath = Join-Path -Path C:\ -ChildPath (Split-Path -Path $DomainBlobFilePath -Leaf)
  Invoke-Command -Session $Session -ScriptBlock {Djoin.exe /RequestODJ /loadfile $using:LocalDomainBlobFilePath /windowspath c:\windows /localos}

  Remove-PSSession $Session

  Restart-Computer -ComputerName $ComputerName -Protocol WSMan -Credential $Credential
  
  Remove-Item -Path $DomainBlobFilePath

}