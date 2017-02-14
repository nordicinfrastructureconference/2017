# Toggle regions: Ctrl + M

#region Demo setup
Write-Warning 'This is a demo script which should be run line by line or sections at a time, stopping script execution'

break

<#

    Author:      Jan Egil Ring & Øyvind Kallstad, Crayon AS
    Name:        05 - AppVeyor.ps1
    Description: This demo script is part of the presentation
                 DevOps for Ops - Automate All the Things!

#>




#region Demo 1

# 01 https://www.appveyor.com/
& 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe' 'https://www.appveyor.com/'

# 02 - Add new project

# 03 Update appveyor.yml
$path = '~\Documents\GitHub\Crayon.Demo.DevOps\Module\0.3\*'
$destination = '~\Documents\GitHub\NIC.ServerDeployment'
Copy-Item -Path $path -Destination $destination -Recurse -Force
