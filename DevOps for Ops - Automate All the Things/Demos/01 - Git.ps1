# Toggle regions: Ctrl + M

#region Demo setup
Write-Warning 'This is a demo script which should be run line by line or sections at a time, stopping script execution'

break

<#

    Author:      Jan Egil Ring & Øyvind Kallstad, Crayon AS
    Name:        01 - Git.ps1
    Description: This demo script is part of the presentation
                 DevOps for Ops - Automate All the Things!

#>

<#
    Putting your code into a version control system is one of the most important steps
    in creating an automated pipeline model. We are going to use GitHub; one of the more popular
    hosted git services.

    It's benefits include:
    - backup of your code
    - version control
    - multiple collaborators
    - issue tracking
    - project management
#>


# 01 - Create new Repository in GitHub
# NIC.ServerDeployment
& 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe' 'https://github.com/CrayonAS'
'NIC.ServerDeployment' | Set-Clipboard

# 02 - Clone Repository (Visual Studio Code)
#      F1 - git - clone - choose folder
Push-Location '~\Documents\GitHub'
git clone 'https://github.com/CrayonAS/NIC.ServerDeployment.git'

# 03 - Copy code to Repository
$path = '~\Documents\GitHub\Crayon.Demo.DevOps\Module\0.1\*'
$destination = '~\Documents\GitHub\NIC.ServerDeployment'
Copy-Item -Path $path -Destination $destination -Recurse -Force

code $destination

# 04 - Sync and show code in GitHub
Push-Location $destination
git add *
git commit -m 'first commit'
git push origin master

# 05 - Update code, sync, show in GitHub
$path = '~\Documents\GitHub\Crayon.Demo.DevOps\Module\0.2\*'
$destination = '~\Documents\GitHub\NIC.ServerDeployment'
Copy-Item -Path $path -Destination $destination -Recurse -Force

Push-Location $destination
git add *
git commit -m 'add vmmserver parameter'
git push origin master

Pop-Location