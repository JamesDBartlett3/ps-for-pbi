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

# PowerShell dependencies
#Requires -Modules MicrosoftPowerBIMgmt

Login-PowerBI

$token = (Get-PowerBIAccessToken)["Authorization"]
# Workspace ID
$groupId = '<ID>'

# a function that detects the URI of PowerBI the cluster where the workspace is currently located
function get-powerbiAPIclusterURI () {
  $reply = Invoke-RestMethod -uri "https://api.powerbi.com/v1.0/myorg/datasets" -Headers @{ "Authorization"=$token } -Method GET
  $unaltered = $reply.'@odata.context'
  $stripped = $unaltered.split('/')[2]
  $clusterURI = "https://$stripped/beta/myorg/groups"
  return $clusterURI
}

function getWorkspaceUsageMetrics($workspaceId) {
    $url = get-powerbiAPIclusterURI
    $data = Invoke-WebRequest -Uri "$url/$workspaceId/usageMetricsReportV2?experience=power-bi" -Headers @{ "Authorization"=$token }
    $response = $data.Content.ToString().Replace("nextRefreshTime", "NextRefreshTime").Replace("lastRefreshTime","LastRefreshTime") | ConvertFrom-Json
    return $response.models[0].dbName
}


$result = getWorkspaceUsageMetrics -workspaceId $groupId
$result