<#
  .SYNOPSIS
    Exports a list of all Power BI workspaces and their members to an Excel file.
  
  .DESCRIPTION
    This script exports a list of all Power BI workspaces and their members to an Excel file.
    It first authenticates with Power BI using an access token. If the access token is not available, 
		it prompts the user to authenticate with Azure Active Directory.
    It then retrieves a list of all workspaces in the organization, excluding those that are deleted, 
		not of type "Workspace", orphaned, or listed in the IgnoreList.json file.
    The resulting list of workspaces and their members is then exported to an Excel file with a timestamp in the filename. 
		This can be useful for auditing and security purposes.
  
  .NOTES
    ACKNOWLEDGEMENTS:
      - Thanks to my wife (@likeawednesday@techhub.social) for her support and encouragement.
      - Thanks to the PowerShell and Power BI/Fabric communities for being so awesome.
  
  .LINK
    [Source code](https://github.com/JamesDBartlett3/PowerBits)
  
  .LINK
    [The author's blog](https://datavolume.xyz)
  
  .LINK
    [Follow the author on LinkedIn](https://www.linkedin.com/in/jamesdbartlett3/)
  
  .LINK
    [Follow the author on Mastodon](https://techhub.social/@JamesDBartlett3)
  
  .LINK
    [Follow the author on BlueSky](https://bsky.app/profile/jamesdbartlett3.bsky.social)
#>

#Requires -PSEdition Core
#Requires -Modules MicrosoftPowerBIMgmt, ImportExcel

try {
	Get-PowerBIAccessToken | Out-Null
}
catch {
	Write-Host '🔒 Power BI Access Token required. Launching Azure Active Directory authentication dialog...'
	Start-Sleep -s 1
	Connect-PowerBIServiceAccount -WarningAction SilentlyContinue | Out-Null
}
finally {
	Write-Host '🔑 Power BI Access Token acquired.'
	$currentDate = Get-Date -UFormat "%Y-%m-%d_%H%M"
	$OutputFileName = "Power BI Workspace Security Audit ($currentDate).xlsx"
  
	# Get names of Workspaces to ignore from IgnoreList.json file
	# Most of these are template apps and/or auto-generated by Microsoft
	[PSCustomObject]$ignoreObjects = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "IgnoreList.json") | ConvertFrom-Json
	[array]$ignoreWorkspaces = $ignoreObjects.IgnoreWorkspaces
  
	$workspaces = Get-PowerBIWorkspace -Scope Organization -All |
	Where-Object {
		$_.State -NE "Deleted" -AND
		$_.Type -EQ "Workspace" -AND
		$_.IsOrphaned -EQ $False -AND
		$_.Name -NotIn $ignoreWorkspaces
	} |
	Select-Object -Property Id, Name |
	Sort-Object -Property Name -Unique
  
	$result = @()
  
	ForEach ($w in $workspaces) {
		$workspaceName = $w.Name
		$workspaceId = $w.Id
		"Getting results for workspace: `e[38;2;255;0;0m$workspaceName`e[0m (Id: `e[38;2;0;255;0m$workspaceId`e[0m)" |
		Write-Host
		$pbiURL = "https://api.powerbi.com/v1.0/myorg/groups/$workspaceId/users"
		$resultJson = Invoke-PowerBIRestMethod -Url $pbiURL -Method GET -ErrorAction SilentlyContinue
		$resultObject = ConvertFrom-Json -InputObject $resultJson
		$result += $resultObject.Value |
		Select-Object @{n = 'workspaceId'; e = { $workspaceId } },
		@{n = 'workspaceName'; e = { $workspaceName } },
		@{n = 'userName'; e = { $_.displayName } },
		@{n = 'userRole'; e = { $_.groupUserAccessRight } },
		@{n = 'userType'; e = { $_.principalType } },
		@{n = 'emailAddress'; e = { $_.emailAddress } },
		@{n = 'identifier'; e = { $_.identifier } } |
		Sort-Object userRole, userName
		# Write-Host "Waiting 36 seconds to avoid hitting the API limit (200 req/hr)..."
		# Start-Sleep 36
	}
  
	$params = @{
		Path         = Join-Path -Path $env:TEMP -ChildPath $OutputFileName
		Show         = $true
		ClearSheet   = $true
		AutoFilter   = $true
		AutoSize     = $true
		FreezeTopRow = $true
		BoldTopRow   = $true
	}
	$result |
	Select-Object -Property workspaceId, workspaceName, emailAddress, userRole, userType |
	Sort-Object -Property workspaceName, userRole, emailAddress | Export-Excel @params
}