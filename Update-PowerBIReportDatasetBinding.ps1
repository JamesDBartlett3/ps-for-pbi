<#
  .SYNOPSIS
    Rebinds a report to a different dataset in Power BI
  
  .DESCRIPTION
		Rebinds a report to a different dataset in Power BI. User will be prompted for the dataset ID, report ID, and group (workspace) ID if they do not specify them as parameters.
  
	.PARAMETER TargetDatasetID
		The ID of the dataset to rebind the report to.
	
	.PARAMETER ReportWorkspaceID
		The ID of the workspace that the report is in.
	
	.PARAMETER ReportID
		The ID of the report to rebind.
	
  .EXAMPLE
    .\Update-PowerBIReportDatasetBinding.ps1
  
  .NOTES
    Warning: This script uses an internal API that is not officially supported by Microsoft. It may break at any time. Use at your own risk.
  
  .LINK
    [Source code](https://github.com/JamesDBartlett3/ps-for-pbi/blob/master/Update-PowerBIReportDatasetBinding.ps1)
  
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
	[Parameter(Mandatory = $false)][guid]$TargetDatasetID,
	[Parameter(Mandatory = $false)][guid]$ReportWorkspaceID,
	[Parameter(Mandatory = $false)][guid]$ReportID
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

function PostRebind {
	param(
		[string]$dataset,
		[string]$report,
		[string]$group
	)
    
	$preparedBody = @{ 'datasetId' = $dataset }
    
	try {
		Invoke-PowerBIRestMethod -Url "groups/$($group)/reports/$($report)/Rebind" -Method Post -Body ($preparedBody | ConvertTo-Json)
		Write-Host -ForegroundColor Green 'The rebinding process has finished successfully'
	}
 catch {
		$_.Exception
	}
    
}

<# PROMPT #>
function ShowPrompt() {
	while ($true) {
		while ($true) {
			Write-Host -ForegroundColor Yellow 'Report Rebinder'
			Write-Host 'Choose action:'
			Write-Host ' [r] - Start Rebinding'
			Write-Host ' [q] - Quit'
    
			$action = Read-Host -Prompt 'Please, choose action'
    
			break
		}
    
		if ($action -and ($action.ToLower() -ne 'r')) {
			if ($action.ToLower() -eq 'q') {
				Write-Host 'Have a nice day!'
				return $false | Out-Null
                
			}
			Clear-Host
			Write-Host -ForegroundColor Red '  Invalid action!  '
			Write-Host ''
		}
		elseif ($action.ToLower() -eq 'r') {
			break
		}
	}
  
	$targetDatasetId = Read-Host -Prompt 'Enter target dataset ID'
	if (!$targetDatasetId) {
		Write-Error 'Invalid dataset id'
	}
    
	$targetGroupId = Read-Host -Prompt 'Enter group (workspace) ID'
	if (!$targetGroupId) {
		Write-Error 'Invalid group id'
	}
    
	$targetReportId = Read-Host -Prompt 'Enter report ID'
	if (!$targetReportId) {
		Write-Error 'Invalid report id'
	}
        
	if ($action -eq 'r') {
		PostRebind -dataset $targetDatasetId -group $targetGroupId -report $targetReportId
	}
}

# Main
if ($TargetDatasetID -and $ReportWorkspaceID -and $ReportID) {
	PostRebind -dataset $TargetDatasetID -group $ReportWorkspaceID -report $ReportID
}
else {
	ShowPrompt
}