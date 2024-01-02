<#
  .SYNOPSIS
    ----
  
  .DESCRIPTION
    ----
  
  .EXAMPLE
    .\Move-RebindReportToDifferentDataset.ps1
  
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

function Post-Rebind {
    param(
        [string]$dataset,
        [string]$report,
        [string]$group
    )
    
    $preparedBody = @{ "datasetId" = $dataset }
    
    try {
        Invoke-PowerBIRestMethod -Url "groups/$($group)/reports/$($report)/Rebind" -Method Post -Body ($preparedBody | ConvertTo-Json)
        Write-Host -ForegroundColor Green "The rebinding process has finished successfully"
    }
    catch {
        $_.Exception
    }
    
}

<# PROMPT #>
function ShowPrompt() {
    while ($true) {
        while ($true) {
            Write-Host -ForegroundColor Yellow "Report Rebinder"
            Write-Host "Choose action:"
            Write-Host " [r] - Start Rebinding"
            Write-Host " [q] - Quit"
    
            $action = Read-Host -Prompt "Please, choose action"
    
            break
        }
    
        if ($action -and ($action -ne "r")) {
            if ($action -eq "q") {
                Write-Host "Have a nice day!"
                return $false | Out-Null
                
            }
            Clear-Host
            Write-Host -ForegroundColor Red "  Invalid action!  "
            Write-Host ""
        }
        elseif ($action -eq "r") {
            break
        }
    }
    Login-PowerBI
    
    $targetDatasetId = Read-Host -Prompt "Enter target dataset ID"
    if (!$targetDatasetId) {
        Write-Error "Invalid dataset id"
    }
    
    $targetGroupId = Read-Host -Prompt "Enter group (workspace) ID"
    if (!$targetGroupId) {
        Write-Error "Invalid group id"
    }
    
    $targetReportId = Read-Host -Prompt "Enter report ID"
    if (!$targetReportId) {
        Write-Error "Invalid report id"
    }
        
    if ($action -eq "r") {
        Post-Rebind -dataset $targetDatasetId -group $targetGroupId -report $targetReportId
    }
}

<# START OF CODE #>
ShowPrompt