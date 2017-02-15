# validate types - continued

function Test-IP {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ipaddress] $IpAddress
    )

    $IpAddress
}

Test-IP 10.0.0.100
#Test-IP 900.65.0.1