#More PowerShell Remoting Demos

return "This is a demo file you silly man."

#region But first...Trusted hosts

Get-Item -Path WSMan:\localhost\Client\TrustedHosts
#this must be run elevated
Set-item -Path WSMan:\localhost\Client\TrustedHosts -Value "172.16.*" -force -PassThru

Set-item -Path WSMan:\localhost\Client\TrustedHosts -Value "DMZ-*" -Concatenate -force -PassThru

Get-Item -Path WSMan:\localhost\Client\TrustedHosts

#or use Group Policy

#endregion

#region creating multiple sessions at once

$cred = Get-Credential globomantics\administrator

$a = New-PSSession chi-dc04 -Credential $cred

invoke-command -ScriptBlock { 
 dir Cert:\LocalMachine\my 
} -session $a

#save to variables
$b,$c,$d = New-PSSession chi-web02,chi-fp02,chi-core01 -Credential $cred

$b;$c;$d

#or
$e = new-pssession chi-test01,chi-sql01,chi-test02 -Credential $cred
$e

invoke-command { get-service bits } -session $e

invoke-command {$psversiontable.psversion.ToString() } -session (Get-PSSession)

#need an object to get computer name
invoke-command {
[pscustomobject]@{PSVersion = $psversiontable.psversion.ToString()}
 } -session (Get-PSSession)

#run a local function remotely
Function Get-Info {
[cmdletbinding()]
Param()

[pscustomobject]@{
PSVersion = $psversiontable.psversion.ToString()
OSVersion = (Get-CimInstance -Class Win32_OperatingSystem).Caption
Computername = hostname
}

} #close Get-Info

#test it locally
Get-Info

$sb = (Get-Item Function:\Get-Info).Scriptblock

#join with + not commas
Invoke-command $sb -session ($e+$b+$c+$d)

#cleaner
Invoke-command $sb -session ($e+$b+$c+$d) -HideComputerName | 
Select * -ExcludeProperty RunspaceID

#or you can use -Filepath with Invoke-command

#endregion

#region Copy file over PSSession

help copy-item -param *Session

$all = Get-Pssession | where state -eq 'opened'

#create a remote folder if it doesn't exist
icm { if (-not (Test-Path c:\work)) { mkdir C:\work }} -session $all

set-content -path .\File.txt -Value (Get-Process)
dir .\File.txt

#copy to a single session
#destination is relative to remote computer
dir .\file.txt | copy -Destination c:\work -ToSession $a

icm { dir c:\work\file.txt} -session $a

#what about multiple servers?
#this will fail
dir .\file.txt | copy -Destination c:\work -ToSession $all

$all | ForEach-Object { 
copy -Path .\File.txt -Destination c:\work -ToSession $_
}

icm { dir c:\work\file.txt} -session $all

#from sessions
copy -Path c:\windows\WindowsUpdate.log -Destination . -FromSession $c -PassThru
dir

copy -Path c:\windows\WindowsUpdate.log -Destination ".\WU.log" -FromSession $c

$all | foreach { 
 copy -Path C:\Windows\WindowsUpdate.log -Destination .  -FromSession $_
 rename-item .\WindowsUpdate.log ".\$($_.computername).WindowsUpdate.log"
 }

#limitations: can't rename, no passthru

#endregion

#region Scaling background jobs over remoting
cls
$computers = $all.computername
$computers

measure-command {
$disk = get-ciminstance win32_logicaldisk -filter "deviceid='c:'" -ComputerName $computers
}
$disk

#now run the same command remotely
#this is creating ad-hoc pssessions on the fly
measure-command {
$disk = icm {
 get-ciminstance win32_logicaldisk -filter "deviceid='c:'"
 } -session $all}

$disk

#using remoting with jobs
$sb = {
Param([string]$Path)
dir $path -Recurse -file | 
Where Extension |
Group {$_.Extension.Substring(1)} |
Select Count,Name,@{Name="Size";
Expression = {($_.group | measure -Property length -sum).sum}} |
sort Size -Descending
}

#create the job locally
$j = invoke-command $sb -session $all -ArgumentList c:\windows\temp -AsJob
$j
$j | get-job -IncludeChildJob
$r = Receive-job $j -Keep
$r
$r | sort PSComputername | 
format-table -GroupBy PSComputername -Property Count,Name,Size

#create the job remotely. Requires sessions
#You may need to separate by PSVersion
$x = icm { [pscustomobject]@{PS=$PSVersionTable.PSVersion.Major} } -session $all
$y = $x.where({$_.PS -eq 4},'split') 
$v4 = $y[0] | foreach { $in = $_; $all.where({$_.Computername -eq $in.PSComputername}) }
$v5 = $y[1] | foreach { $in = $_; $all.where({$_.Computername -eq $in.PSComputername}) }

Invoke-Command -ScriptBlock { 
#need to recreate the scriptblock due to remoting
$run = [scriptblock]::Create($using:sb)
Start-job -scriptblock $run  -Name DirSize -ArgumentList C:\windows\temp
} -session $v4

Invoke-Command -ScriptBlock { 
#need to recreate the scriptblock due to remoting
$run = [scriptblock]::Create($using:sb)
Start-job -scriptblock $run  -Name DirSize -ArgumentList C:\windows\temp
} -session $v5

Invoke-Command { get-job dirsize } -session $all
Invoke-Command { get-job dirsize | Select ID,Name,State,PSComputername } -session $all | format-table

$r = Invoke-Command { receive-job dirsize -Keep } -session $all
$r | sort PSComputername | 
format-table -GroupBy PSComputername -Property Count,Name,Size

#also a good reason to use Disconnected Sessions

# icm { remove-job DirSize } -Session $all

#endregion

#region Using SSL
Test-WSMan chi-core01
Test-WSMan chi-core01 -UseSSL

psedit .\Configure-SSLRemoting.ps1

#endregion

#region 2nd Hop

#The problem
enter-pssession chi-sql01
dir \\chi-fp02\it

#region Using CredSSP
Get-WSManCredSSP
enable-wsmancredssp -Role Client -DelegateComputer chi-fp02 -force
exit

enter-pssession chi-fp02
Get-WSManCredSSP
Enable-WSManCredSSP -Role Server -force
exit

#reconnect with explict credentials and CredSSP
#this may require additional WSMan settings. Read any error messages
Enter-PSSession -ComputerName chi-sql01 -Credential globomantics\jeff -Authentication Credssp
dir \\chi-fp02\it

#undo
Disable-WSManCredSSP -Role client
Get-WSManCredSSP

icm { Disable-WSManCredSSP -role server} -computername chi-fp02

#endregion

#region Using Resource based Kerberos Constrained Delegation
#read https://blogs.technet.microsoft.com/ashleymcglone/2016/08/30/powershell-remoting-kerberos-double-hop-solved-securely/

# this needs the AD module

$server = Get-ADComputer chi-fp02
$client = Get-ADComputer chi-sql01

# Get-CimInstance Win32_Service -Filter 'Name="winrm"' -ComputerName $client.name | Select Startname
#setup the delegation
Set-ADComputer -Identity $Server -PrincipalsAllowedToDelegateToAccount $client

#verify
Get-ADComputer -Identity $Server -Properties PrincipalsAllowedToDelegateToAccount

#need to purge tickets due to 15min SPN negative cache
Invoke-Command -ComputerName $Server.Name  -ScriptBlock {            
    klist purge -li 0x3e7            
}

enter-pssession chi-sql01
dir \\chi-fp02\it

Get-WSManCredSSP
exit

#Undo
Set-ADComputer -Identity $Server -PrincipalsAllowedToDelegateToAccount $null

#endregion

#endregion

#region Implicit remoting

psedit .\demo-implicitremoting.ps1

#endregion

