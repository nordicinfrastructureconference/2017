function Connect-VMConsole {
  param
  ($VMName,
  $VMHost)

  Start-Process -FilePath vmconnect.exe -ArgumentList $VMHost,$VMName

}