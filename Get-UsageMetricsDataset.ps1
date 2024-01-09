<#
  .SYNOPSIS
  ----
  
  .DESCRIPTION
  ----
  
  .EXAMPLE
  # Get the usage metrics for a workspace
  .\Get-UsageMetricsDataset.ps1 -WorkspaceID 12345678-1234-1234-1234-123456789012
  
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
  [Parameter(Mandatory = $false)][guid]$WorkspaceID,
  [Parameter(Mandatory = $false)][string]$OutFile
)

# PowerShell dependencies
#Requires -Modules MicrosoftPowerBIMgmt

$headers = [System.Collections.Generic.Dictionary[[String], [String]]]::New()

try {
  $headers = Get-PowerBIAccessToken
}

catch {
  Write-Host '🔒 Power BI Access Token required. Launching Azure Active Directory authentication dialog...'
  Start-Sleep -s 1
  Connect-PowerBIServiceAccount -WarningAction SilentlyContinue | Out-Null
  $headers = Get-PowerBIAccessToken
  if ($headers) {
    Write-Host '🔑 Power BI Access Token acquired. Proceeding...'
  }
  else {
    Write-Host '❌ Power BI Access Token not acquired. Exiting...'
    Exit
  }
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
  $psRequestBody = @{
    queries            = @(
      @{
        query = "EVALUATE 'Report views'"
      }
    )
    serializerSettings = @{
      includeNulls = $false
    }
  }
  $url = Get-PowerBiApiClusterUri
  $data = Invoke-WebRequest -Uri "$url/$wid/usageMetricsReportV2?experience=power-bi" -Headers @{ 'Authorization' = $token }
  $response = $data.Content.ToString().Replace('nextRefreshTime', 'NextRefreshTime').Replace('lastRefreshTime', 'LastRefreshTime') | ConvertFrom-Json
  $dmname = $response.models[0].dbName
  $publicEndpoint = "https://api.powerbi.com/v1.0/myorg/groups/$wid/datasets/$dmname/executeQueries"
  $result = Invoke-PowerBIRestMethod -Method POST -Url $publicEndpoint -Body ($psRequestBody | ConvertTo-Json)
  $jsonResult = $result | ConvertFrom-Json
  $reportViewed = $jsonResult.results[0].tables[0].rows
  return $reportViewed
}

$result = Get-WorkspaceUsageMetrics -wid $WorkspaceID
$columnNames = $result[0].PSObject.Properties.Name
$newColumnNames = $columnNames.ForEach({$_.Replace('Report views', '').Replace("[","").Replace("]","")})

for ($i = 0; $i -lt $columnNames.length; $i++) {
  $result | Add-Member -MemberType AliasProperty -Name $newColumnNames[$i] -Value $columnNames[$i]
}

$resultPath = if ( !$OutFile -or $OutFile -notlike "*.csv" ) {
    Join-Path -Path $env:TEMP -ChildPath 'ReportViews.csv'
  } else {
    $OutFile
  }

$result | Select-Object -Property $newColumnNames | Export-Csv -Path $resultPath
Write-Host "Saving file to $resultPath"
Invoke-Item $resultPath