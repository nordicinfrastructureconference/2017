#demo on setting up SSL remoting
#assumes a domain based PKI

Return "This is a demo file to step through."

cls
$computer = "chi-core01"

#http listener
Get-WSManInstance -resourceuri winrm/config/listener -selectorset @{address="*";transport="http"} -ComputerName $computer

#https listener
Get-WSManInstance -resourceuri winrm/config/listener -selectorset @{address="*";transport="https"} -ComputerName $computer

#you need to install a certificate with the Server Authentication
#usage tag. AD PKI works nicely but it is up to you to figure out
#how to do this.

#get certificate thumbprint
$cert = invoke-command { 
dir cert:\localmachine\my | 
where {$_.EnhancedKeyUsageList -match "Server Authentication"} | 
select -first 1 } -computername $computer

$cert

#verify DNS name and IP
$dns = Resolve-DnsName -Name $computer -TcpOnly
$dns
test-connection $computer

#create a new listener
#parameters for New-WSManInstance settings
$settings =  @{
 Address = $dns.IPAddress
 Transport = "https"
 CertificateThumbprint = $cert.Thumbprint
 Enabled = "True"
 Hostname = $cert.DnsNameList.unicode
} 

$settings

#parameters to splat to New-WsmanInstance
$hash = @{
resourceuri = 'winrm/config/listener'
selectorset = @{Address="*";Transport="HTTPS"} 
ValueSet = $settings 
ComputerName = $computer 
Verbose = $True
}
New-WSManInstance @hash
 
Get-WSManInstance -resourceuri winrm/config/listener -selectorset @{address="*";transport="https"} -ComputerName $computer 

#Test the connection
#names must match certificate

test-wsman $computer -UseSSL #<--this will fail

test-wsman $dns.name -UseSSL

$n = New-PSSession $dns.Name -UseSSL
$n.Runspace.ConnectionInfo

netstat -an | select-string :5986

icm { dir c:\} -computername $dns.Name -UseSSL



<#
hostname must match certificate name

Remove-WSManInstance -resourceuri winrm/config/listener -selectorset @{address="*";transport="https"} -ComputerName $computer

test-wsman $dns.name -UseSSL

enter-pssession $computer
#>
