# relative paths
function Get-ContentRelativeToModule1 {
    Get-Content -Path .\read.me
}

function Get-ContentRelativeToModule2 {
    Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath 'read.me')
}