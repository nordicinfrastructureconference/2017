
# Create a Dynamic Group for my test users of Seinfeld characters
New-AzureADMSGroup -DisplayName "Seinfeld Users" -Description "Dynamic groups with all Seinfeld users" -MailEnabled $false -SecurityEnabled $true -MailNickname "seinfeld" -GroupTypes "DynamicMembership" -MembershipRule "(user.department -eq ""Seinfeld"")" -MembershipRuleProcessingState "Paused"

# Get Group and members
$AADGroup = Get-AzureADMSGroup -SearchString "Seinfeld Users"
Get-AzureADGroupMember -ObjectId $AADGroup.Id

# Set Membership Processing
$AADGroup | Set-AzureADMSGroup -MembershipRuleProcessingState On

# Save members to object variable
$members = Get-AzureADGroupMember -ObjectId $AADGroup.Id

# Set User Thumbnail Photo
# Note that setting Thumbnailphoto can only be set against cloud mastered objects, or else error message:
# Unable to update the specified properties for on-premises mastered Directory Sync objects or objects currently undergoing migration.
Set-AzureADUserThumbnailPhoto -ObjectId <myuserupn or objectid> -FilePath C:\_source\temp\jan.vidar@elven.no.jpg

# Get and View User Thumbnail Photo
Get-AzureADUserThumbnailPhoto -ObjectId <myuserupn or objectid> -view $true

#region License management for a collection of users
# For example assigning EMS E5 license plan

# Get SkuId for EMS E5 (EMS PREMIUM)
$EmsSkuId = (Get-AzureADSubscribedSku | Where { $_.SkuPartNumber -eq 'EMSPREMIUM'}).SkuId

ForEach ($member in $members) {

    # Get the user
    $User = Get-AzureADUser -ObjectId $member.ObjectId  

    # Create a License Object for assigning the wanted SkuId
    $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense 
    $License.SkuId = $EmsSkuId

    # Create a Licenses Object for Adding the License
    $Licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses 
    $Licenses.AddLicenses = $License 
    # If I wanted to remove licenses I would use .RemoveLicenses instead
    
    # And lastly, update User license with added (or removed) licenses
    Set-AzureADUserLicense -ObjectId $User.ObjectId -AssignedLicenses $Licenses

}

#endregion


# Reset a Users password
# Note that synchronized users need Azure AD Premium, and Azure AD Connect with Password Write-Back Configured
$password = Read-Host -AsSecureString

Set-AzureADUserPassword -ObjectId  "df19e8e6-2ad7-453e-87f5-037f6529ae16" -Password $password

# Change (not Reset) the current logged on users password
Update-AzureADSignedInUserPassword -CurrentPassword $CurrentPassword -NewPassword $NewPassword
