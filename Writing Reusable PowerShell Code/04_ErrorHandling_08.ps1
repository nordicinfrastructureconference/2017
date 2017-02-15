# try-catch

try {
    Get-Content -Path 'C:\users\ojk\Documents\NIC2017\Service2.log'
    #Get-Content -Path 'C:\users\ojk\Documents\NIC2017\Service3.log'
    #Get-Content -Path 'C:\users\ojk\Documents\NIC2017\Service3.log' -ErrorAction Stop
    Write-Host 'try'
}

catch {
    Write-Warning "Error reading logfile"
}

finally {
    Write-Host 'finally'
}
