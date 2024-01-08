<#
  .SYNOPSIS
    ----
  
  .DESCRIPTION
    ----
  
  .EXAMPLE
    .\Get-UsageMetricsDataset.ps1
  
  .NOTES
    ----
  
  .LINK
    [Source code](https://github.com/JamesDBartlett3/ps-for-pbi)
  
  .LINK
    [The author's blog](https://datameerkat.com/)
    
  .LINK
    [Follow the author on LinkedIn](https://www.linkedin.com/in/stepan-resl/)
  
  .LINK
    [Follow the author on Mastodon](https://techhub.social/deck/@StepanResl)
  
  .LINK
    [Follow the author on BlueSky](https://bsky.app/profile/stepanresl.bsky.social)
#>

Param(
  [Parameter(Mandatory = $false)][guid]$WorkspaceID
)

# PowerShell dependencies
#Requires -Modules MicrosoftPowerBIMgmt

$headers = [System.Collections.Generic.Dictionary[[String],[String]]]::New()

try {
  $headers = Get-PowerBIAccessToken
}
catch {
  Write-Host '🔒 Power BI Access Token required. Launching Azure Active Directory authentication dialog...'
  Start-Sleep -s 1
  Connect-PowerBI -WarningAction SilentlyContinue | Out-Null
  $headers = Get-PowerBIAccessToken
}
if ($headers) {
	Write-Host '🔑 Power BI Access Token acquired. Proceeding...'
}
else {
	Write-Host '❌ Power BI Access Token not acquired. Exiting...'
	exit
}

$token = $headers['Authorization']

# Workspace ID
if (!$WorkspaceID) {
  $WorkspaceID = Read-Host -Prompt 'Enter the workspace ID'
}

# a function that detects the URI of PowerBI the cluster where the workspace is currently located
function Get-PowerBiApiClusterUri() {
  $reply = Invoke-RestMethod -Uri 'https://api.powerbi.com/v1.0/myorg/datasets' -Headers @{ 'Authorization' = $token } -Method GET
  $unaltered = $reply.'@odata.context'
  $stripped = $unaltered.split('/')[2]
  $clusterURI = "https://$stripped/beta/myorg/groups"
  return $clusterURI
}

function Get-WorkspaceUsageMetrics($wid) {
  $url = Get-PowerBiApiClusterUri
  $data = Invoke-WebRequest -Uri "$url/$wid/usageMetricsReportV2?experience=power-bi" -Headers @{ 'Authorization' = $token }
  $response = $data.Content.ToString().Replace('nextRefreshTime', 'NextRefreshTime').Replace('lastRefreshTime', 'LastRefreshTime') | ConvertFrom-Json
  return $response.models[0].dbName
}

$result = Get-WorkspaceUsageMetrics -wid $WorkspaceID

Write-Host "Usage Metrics Dataset ID: $result"