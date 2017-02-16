# This Application is for accessing the Azure AD Graph Api

# Log in to Azure AD with Global Admin
Connect-AzureAD

# Create the Azure AD API Application
$azureAdApp = New-AzureADApplication -DisplayName "Elven Azure AD Reporting Api App" -Homepage "https://localhost" -IdentifierUris "https://localhost/azureadreportingapi" -ReplyUrls "https://localhost"

$keyStartDate = "{0:s}" -f (get-date).AddHours(-1) + "Z"
$keyEndDate = "{0:s}" -f (get-date).AddYears(1) + "Z"

# Create Password Key Secret
$azureAdAppKeySecret = New-AzureADApplicationPasswordCredential -ObjectId $azureAdApp.ObjectId -CustomKeyIdentifier "Azure AD Api Reporting Key" -StartDate $keyStartDate -EndDate $keyEndDate

# Get the Azure AD SPN
$azureAdSpn = Get-AzureADServicePrincipal -Filter "DisplayName eq 'Microsoft.Azure.ActiveDirectory'"

# Get the Oauth2 permissions for Read and Sign-in plus Directory Read
$azureAdOauth2UserSignInProfileRead = $azureAdSpn | Select-Object -expand Oauth2Permissions | ? {$_.value -eq "User.Read"}
$azureAdOauth2DirectoryRead = $azureAdSpn | Select-Object -expand Oauth2Permissions | ? {$_.value -eq "Directory.Read.All"}

# Build a Required Resource Access Object with permissions for User.Read + Sign in and Directory Read
$requiredResourceAccess = [Microsoft.Open.AzureAD.Model.RequiredResourceAccess]@{
  ResourceAppId=$azureAdSpn.AppId ;
  ResourceAccess=[Microsoft.Open.AzureAD.Model.ResourceAccess]@{
    Id = $azureAdOauth2UserSignInProfileRead.Id ;
    Type = "Scope"
    },
    [Microsoft.Open.AzureAD.Model.ResourceAccess]@{
    Id = $azureAdOauth2DirectoryRead.Id ;
    Type = "Role"
    }
}

# Set the required resources for the Azure AD Application
Set-AzureADApplication -ObjectId $azureadapp.ObjectId -RequiredResourceAccess $requiredResourceAccess
 
# Associate a new Service Principal to my Azure AD Application 
$appspn = New-AzureADServicePrincipal -AppId $azureadapp.AppId -Tags @("WindowsAzureActiveDirectoryIntegratedApp")

# Add Permission Grant for that App Service Principal to the Microsoft.Azure.ActiveDirectory API
## This is the only thing that cannot be automated by now!
### Go to the Azure Portal and your Azure AD, under App Registrations, find this Reporting Api App, and under Permissions select to Grant Permission

# Remove Permission Grant if no longer needed
$azureAdSpnPermissionGrant = Get-AzureADOAuth2PermissionGrant | Where-Object {$_.ResourceId -eq $azureAdSpn.ObjectId} | Where-Object {$_.ClientId -eq $appspn.ObjectId}
Remove-AzureADOAuth2PermissionGrant -ObjectId $azureAdSpnPermissionGrant.ObjectId

