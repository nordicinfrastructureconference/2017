
#region send initial data

$Data = [PSCustomObject]@{
    Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    Property1 = "Value1"
    Property2 = 1234
    Property3 = "Value3"
}

$json = $Data | ConvertTo-Json
Invoke-RestMethod -Method POST -Uri "http://localhost:9200/testindex/test-1" -Body $json

#endregion

#region new date

function New-DateTime {
    param(
        [DateTime]$Min = "2016/4/1",
        [DateTime]$Max = [DateTime]::Now,
        [String]$Format = "yyyy-MM-ddTHH:mm:ss.fffZ",
        [System.Random]$RandomGenerator = (new-object random)
    )

    $RandomTicks = [Convert]::ToInt64( ($Max.ticks * 1.0 - $Min.Ticks * 1.0 ) * $RandomGenerator.NextDouble() + $Min.Ticks * 1.0 )
    (new-object DateTime($RandomTicks)).ToUniversalTime().ToString($Format, [cultureinfo]::InvariantCulture)
}

#endregion

#region send log

function Send-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [String]
        $Source,

        [Int32]
        $StatusCode,
        
        [String]
        $Message,
        
        [ValidateSet("Information","Warning","Error","Success")]
        [String]
        $Severity,

        [Object]
        $Object,
        
        [String]
        $Timestamp = (New-DateTime)
    )
    
    if ($PSBoundParameters.Keys -notcontains "Timestamp") {
        $PSBoundParameters.Add("Timestamp", $Timestamp)
    }

    $json = $PSBoundParameters | ConvertTo-Json
    Invoke-RestMethod -Method POST -Uri "http://localhost:9200/scriptlogs/$Source" -Body $json
}

#endregion

#region import-user dummy data

function Import-User {
    [CmdletBinding()]
    param(
        [Int32]
        $Count = 1000
    )

    $random = New-Object random
    
    Foreach ($i in 1..$Count) {
        $User = [PSCustomObject]@{
            ImportTime = New-DateTime
            GivenName = "Andy","Mark","George","Roger","Gary","Michael","James" | Get-Random
            SurName = "Smith","Baker","Brown","Taylor","Williams","Jones","Bond" | Get-Random
            Department = "Finance","Research","Research","Research","Research","Systems Development","Systems Development","Systems Development","Sales","Support","Support","Support","Support","Support","Support","Support","Support","Support","Support","Support","Support","Consulting" | Get-Random
        }

        if ($random.NextDouble() -lt 0.01) {
            Send-Log -Source Import-User -Message "There was an error importing the user" -Severity Error -Object $User
        }
        else {
            Send-Log -Source Import-User -Message "The user was imported successfully" -Severity Success -Object $User
        }
    }
}

#endregion

#region start-maintenance dummy data

function Start-Maintenance {
    [CmdletBinding()]
    param(
        [Int32]
        $Count = 1000
    )

    $Servers = @(
        [PSCustomObject]@{Name="Server01";OperatingSystem="Windows 2012 R2"}
        [PSCustomObject]@{Name="Server02";OperatingSystem="Windows 2012 R2"}
        [PSCustomObject]@{Name="Server03";OperatingSystem="Windows 2012 R2"}
        [PSCustomObject]@{Name="Server04";OperatingSystem="Windows 2016"}
        [PSCustomObject]@{Name="Server05";OperatingSystem="Ubuntu 14.04"}
        [PSCustomObject]@{Name="Server06";OperatingSystem="Ubuntu 16.04"}
    )
    
    Foreach ($i in 1..$Count) {
        $Maintenance = [PSCustomObject]@{
            Server = $Servers | Get-Random
        }

        $Timestamp = New-DateTime
        Send-Log -Source maintenance-1 -Severity Information -Message "Started maintenance" -Object $Maintenance -Timestamp $Timestamp
        Send-Log -Source maintenance-1 -Severity Information -Message "Found X maintenance objects" -Object $Maintenance -Timestamp $Timestamp
        Send-Log -Source maintenance-1 -Severity Warning -Message "Could not get all objects. Maintenance may be incomplete." -Object $Maintenance -Timestamp $Timestamp
        Send-Log -Source maintenance-1 -Severity Information -Message "Deleting old files" -Object $Maintenance -Timestamp $Timestamp
        Send-Log -Source maintenance-1 -Severity Success -Message "X files deleted" -Object $Maintenance -Timestamp $Timestamp
        Send-Log -Source maintenance-1 -Severity Information -Message "Finished Maintenance" -Object $Maintenance -Timestamp $Timestamp
    }
}

#endregion