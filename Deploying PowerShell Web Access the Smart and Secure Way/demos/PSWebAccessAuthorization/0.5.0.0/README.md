# PSWebAccessAuthorization #

A DSC resource for managing PowerShell Web Access (PSWA) authorization rules.

## Current version
The currently released version is 0.5.0.0. You can download from https://github.com/jdhitsolutions/PSWebAccessAuthorization/releases or check the PowerShell Gallery for the PSWebAccessAuthorization module.

## Background
This PowerShell module describes a Desired State Configuration (DSC) resource for managing PowerShell Web Access authorization rules. You can use this resource in a DSC configuration to control rules. 

```
PwaAuthorizationRule [String] #ResourceName {
    Ensure = [string]{ Absent | Present }
    RuleName = [string]
    [Configuration = [string]]
    [DependsOn = [string[]]]
    [Destination = [string]]
    [DestinationType = [string]{ Computer | ComputerGroup }]
    [Domain = [string]]
    [PsDscRunAsCredential = [PSCredential]]
    [Username = [string[]]]
    [UserType = [string]{ User | UserGroup }]
}
```

You can create or remove rules in a configuration like this:

```
PwaAuthorizationRule DBA {
    RuleName = "DBA Access"
    Ensure = "Present"
    Destination = "SqlServerGroup"
    DestinationType = "ComputerGroup"
    Username = @("CompanyDBA")
    UserType = "UserGroup"
}
```

The assumption is that PowerShell Web Access has already been configured and installed. If you are using this resource in the same configuration that is creating a new PSWA server, then make sure you use `DependsOn` for the PwaAuthorizationRule resource.

Detailed information can be found in [about_PSWebAccessAuthorization](.\Docs\about_pswebaccessauthorization.md) 

****************************************************************

_last updated 13 January 2017_
