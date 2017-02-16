# Azure AD v2 PowerShell Quickstart Connect

# Connect with Credential Object
$AzureAdCred = Get-Credential
Connect-AzureAD -Credential $AzureAdCred

# Connect with Modern Authentication
Connect-AzureAD

# Explore some objects
Get-AzureADUser

# Getting users by objectid, upn and searching
Get-AzureADUser -ObjectId <objectid>
Get-AzureADUser -ObjectId jan.vidar@elven.no
Get-AzureADUser -SearchString "Jan Vidar"

# Explore deeper via object variable
$AADUser = Get-AzureADUser -ObjectId jan.vidar@elven.no

$AADUser | Get-Member

$AADUser | FL

# Look at licenses and history for enable and disable
$AADUser.AssignedPlans
# Or
Get-AzureADUser -ObjectId jan.vidar@elven.no | Select-Object -ExpandProperty AssignedPlans

# More detail for individual licenses for plans
Get-AzureADUserLicenseDetail -ObjectId $AADUser.ObjectId | Select-Object -ExpandProperty ServicePlans

# Get your tenants subscriptions, and explore details
Get-AzureADSubscribedSku | FL
Get-AzureADSubscribedSku | Select SkuPartNumber -ExpandProperty PrepaidUnits
Get-AzureADSubscribedSku | Select SkuPartNumber -ExpandProperty ServicePlans

# Invalidate Users Refresh tokens
Revoke-AzureADUserAllRefreshToken -ObjectId $AADUser.ObjectId



