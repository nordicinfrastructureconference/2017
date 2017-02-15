# logical errors
$ErrorActionPreference = 'continue'

# instantiating variable inside the loop
Remove-Variable -Name 'result' -force
1..3 | ForEach-Object {
    $result = @()
    $result += $_ * 2
}
$result

# wrong operator used
Remove-Variable -Name 'result' -force -WarningAction SilentlyContinue
$result = @()
1..3 | ForEach-Object {
    $result = $_ * 2
}
$result

# powershell infers the wrong type for the variable
Remove-Variable -Name 'result' -force
1..3 | ForEach-Object {
    $result += $_ * 2
}
$result

# wrong assumption about return type
$ErrorActionPreference = 'continue'
$disks = Get-WmiObject Win32_LogicalDisk
$disks.foreach{'Do stuff'}

