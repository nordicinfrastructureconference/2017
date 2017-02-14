# test for empty variables

$services = @(
    'spooler',
    'MyService'
)

foreach ($service in $services) {
    $thisService = Get-Service $service
    Write-Host "Doing something with $($thisService.DisplayName)"
}

# FIX
foreach ($service in $services) {
    $thisService = Get-Service $service

    if ($thisService) {
        Write-Host "Doing something with $($thisService.DisplayName)"
    }
}
