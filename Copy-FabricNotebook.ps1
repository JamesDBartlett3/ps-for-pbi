<#
  .SYNOPSIS
    Copies one or more Fabric notebooks from one workspace to another.
  
  .DESCRIPTION
    This script copies one or more Fabric notebooks from one workspace to another.
    It first authenticates with Power BI using an access token. If the access token is not available, it prompts the user to authenticate with Azure Active Directory.
    It then retrieves the specified notebook from the source workspace and copies it to the target workspace.
    This can be useful for migrating notebooks between workspaces.

  .PARAMETER SourceWorkspace
    The name or ID of the source workspace containing the notebook(s) to copy.

  .PARAMETER Notebooks
    The name or ID of the notebook(s) to copy. If not specified, the script will prompt the user to select one or more notebooks from the source workspace.

  .PARAMETER TargetWorkspace
    The name or ID of the target workspace to copy the notebook(s) to.

  .EXAMPLE
    # This example copies the notebooks named 'Notebook A' and 'Notebook B' from the workspace named 'Source Workspace' to the workspace named 'Target Workspace'.
    .\Copy-FabricNotebook.ps1 -SourceWorkspace 'Source Workspace' -TargetWorkspace 'Target Workspace' -Notebooks 'Notebook A', 'Notebook B'
    
  .EXAMPLE
    # This example copies a notebook identified by its ID from a workspace identified by its ID to another workspace identified by its ID.
    .\Copy-FabricNotebook.ps1 -SourceWorkspace '12345678-1234-1234-1234-1234567890ab' -TargetWorkspace '98765432-4321-4321-4321-0987654321ba' -Notebooks '87654321-4321-4321-4321-1234567890ab'
  
  .NOTES
    ACKNOWLEDGEMENTS:
      - Thanks to my wife (@likeawednesday@techhub.social) for her support and encouragement.
      - Thanks to the PowerShell and Power BI/Fabric communities for being so awesome.
  
  .LINK
    [Source code](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Copy-FabricNotebook.ps1)
  
  .LINK
    [The author's blog](https://datavolume.xyz)
  
  .LINK
    [Follow the author on LinkedIn](https://www.linkedin.com/in/jamesdbartlett3/)
  
  .LINK
    [Follow the author on Mastodon](https://techhub.social/@JamesDBartlett3)
  
  .LINK
    [Follow the author on BlueSky](https://bsky.app/profile/jamesdbartlett3.bsky.social)
#>

Param(
  [Parameter(Mandatory)][string]$SourceWorkspace,
  [Parameter(Mandatory)][string]$TargetWorkspace,
  [Parameter()][string[]]$Notebooks
)

#Requires -PSEdition Core
#Requires -Modules MicrosoftPowerBIMgmt, Microsoft.PowerShell.ConsoleGuiTools

begin {
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
  $sourceWorkspaceId = ''
  $targetWorkspaceId = ''
  $fabricUri = 'https://api.fabric.microsoft.com/v1/workspaces'
  $guidMatch = '^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$'
  $selectedNotebooks = @()
  Function Get-PbiFabWorkspaceId {
    Param(
      [string]$WorkspaceName
    )
    $workspaceId = (Invoke-RestMethod -Method GET -Uri "$fabricUri/$sourceWorkspaceId" -Headers $headers).id
    return $workspaceId
  }
  # If $SourceWorkspace is not a GUID, assume it is a workspace name and retrieve the workspace ID.
  $sourceWorkspaceId = $SourceWorkspace -match $guidMatch ? $SourceWorkspace : (Get-PbiFabWorkspaceId -WorkspaceName $SourceWorkspace)
  # If $TargetWorkspace is not a GUID, assume it is a workspace name and retrieve the workspace ID.
  $targetWorkspaceId = $TargetWorkspace -match $guidMatch ? $TargetWorkspace : (Get-PbiFabWorkspaceId -WorkspaceName $TargetWorkspace)
}

process {
  # Retrieve a list of all notebooks in the source workspace.
  $notebooksList = Invoke-RestMethod -Method GET -Uri "$fabricUri/$sourceWorkspaceId/items?type=Notebook" -Headers $headers
  # If Notebooks parameter is left blank, list all notebooks in the source workspace and prompt the user to select one or more of them.
  if (-not $Notebooks) {
    $selectedNotebooks = Show-ConsoleListView -Title 'Select notebook(s) to copy' -Items $notebooksList -MultiSelect
    Write-Host $selectedNotebooks
  }
  else {
    foreach ($notebook in $Notebooks) {
      $selectedNotebooks += $notebooksList | Where-Object { $notebook -in $_.displayName, $_.id }
    }
    Write-Host $selectedNotebooks
  }
  # Copy each notebook to the target workspace.
  foreach ($notebook in $selectedNotebooks) {
    $notebookId = $notebook.Id
    $notebookName = $notebook.Name
    try {
      $notebookContent = Invoke-RestMethod -Method GET -Uri "$fabricUri/$sourceWorkspaceId/items/$notebookId/content" -Headers $headers
      $notebookContent | Invoke-RestMethod -Method POST -Uri "$fabricUri/$targetWorkspaceId/items" -Headers $headers
      Write-Host "📋 Notebook '$notebookName' (ID: $notebookId) copied successfully."
    }
    catch {
      Write-Error "❌ Error copying notebook '$notebookName' (ID: $notebookId)."
    }
  }
}