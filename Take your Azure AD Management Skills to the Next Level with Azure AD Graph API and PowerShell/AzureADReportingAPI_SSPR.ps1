# PowerShell for calling the Azure AD Graph Reporting REST API, https://msdn.microsoft.com/en-us/library/azure/ad/graph/howto/azure-ad-reports-and-events-preview
# Getting Self Service Password Reset Registrations

# This script will require registration of a Web Application in Azure Active Directory 

# Method 1: Use steps here for manually creating required Web App: https://docs.microsoft.com/en-us/azure/active-directory/active-directory-reporting-api-prerequisites
# Method 2: Use Azure AD PowerShell as documented here: https://gist.github.com/skillriver/b46c51e2902a331a91221c6828bd320c#file-azureadapiapplication-ps1 

$loginURL = "https://login.microsoftonline.com"
$tenantdomain = "<yourtenant>.onmicrosoft.com"

# Fill in your App Id and Key Secret
$azureAdAppId = "<app id for azure ad application>"
$azureAdAppKey = "<valid key secret for azure ad application>"

# Create a credential based on already registered Azure AD App Id and Key Secret
$keysecurestring = ConvertTo-SecureString $azureAdAppKey -AsPlainText -Force
$reportingapicred = New-Object System.Management.Automation.PSCredential ($azureAdAppId, $keysecurestring)

# Get an Oauth 2 access token based on client id, secret and tenant domain
$body = @{grant_type="client_credentials";resource=$resource;client_id=$reportingapicred.UserName;client_secret=$reportingapicred.GetNetworkCredential().Password}
$oauth = Invoke-RestMethod -Method Post -Uri $loginURL/$TenantDomain/oauth2/token?api-version=1.0 -Body $body

# Define a header with the authorization token
$headerParams  = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}

# Build the request, here we are looking for SSPR activity
$topResults = 100 # Tweak this value if you want different page size and present it in a report
$reportContent = @()
$reportUrl = "https://graph.windows.net/$TenantDomain/reports/ssprRegistrationActivityEvents?api-version=beta&`$top=$topResults"
$reportCount = 0

# Returns a JSON document for the "ssprRegistrations" report
$ssprRegistrations = (Invoke-WebRequest -Headers $headerParams -Uri $reportUrl -UseBasicParsing).Content | ConvertFrom-Json

# Adding data to the Report
$reportContent += $ssprRegistrations.value | Select -Unique eventTime, role, registrationActivity, displayName, userName

# Showing the Report
$reportContent

# Exporting the Report to a Comma Separated Value file
$reportContent | Export-Csv "ElvenAzureAD_SSPRregistrations.csv" -NoTypeInformation -Delimiter ","
