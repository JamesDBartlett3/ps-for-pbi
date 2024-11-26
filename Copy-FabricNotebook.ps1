<#
  .SYNOPSIS
    Copies one or more Fabric notebooks from one workspace to another.
  
  .DESCRIPTION
    This script copies one or more Fabric notebooks from one workspace to another.
    It first authenticates with Power BI using an access token. If the access token is not available, it prompts the user to authenticate with Azure Active Directory.
    It then retrieves the specified notebook from the source workspace and copies it to the destination workspace.
    This can be useful for migrating notebooks between workspaces.

  .PARAMETER SourceWorkspace
    The name or ID of the source workspace containing the notebook(s) to copy.

  .PARAMETER Notebooks
    The name or ID of the notebook(s) to copy. If not specified, the script will prompt the user to select one or more notebooks from the source workspace.

  .PARAMETER DestinationWorkspace
    The name or ID of the destination workspace to copy the notebook(s) to.

  .EXAMPLE
    # This example copies the notebooks named 'Notebook A' and 'Notebook B' from the workspace named 'Source Workspace' to the workspace named 'Destination Workspace'.
    .\Copy-FabricNotebook.ps1 -SourceWorkspace 'Source Workspace' -DestinationWorkspace 'Destination Workspace' -Notebooks 'Notebook A', 'Notebook B'
    
  .EXAMPLE
    # This example copies a notebook identified by its ID from a workspace identified by its ID to another workspace identified by its ID.
    .\Copy-FabricNotebook.ps1 -SourceWorkspace '12345678-1234-1234-1234-1234567890ab' -DestinationWorkspace '98765432-4321-4321-4321-0987654321ba' -Notebooks '87654321-4321-4321-4321-1234567890ab'
  
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
  [Parameter(Mandatory)][string]$DestinationWorkspace,
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
  $destinationWorkspaceId = ''
  $fabricUri = 'https://api.fabric.microsoft.com/v1/workspaces'
  $guidMatch = '^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$'
  $selectedNotebooks = @()
  Function Get-PbiFabWorkspaceId {
    Param(
      [string]$WorkspaceName
    )
    $workspaceId = ((Invoke-RestMethod -Method GET -Uri $fabricUri -Headers $headers).value | Where-Object { $_.displayName -eq $WorkspaceName }).id
    return $workspaceId
  }
  # If $SourceWorkspace is not a GUID, assume it is a workspace name and retrieve the workspace ID.
  $sourceWorkspaceId = $SourceWorkspace -match $guidMatch ? $SourceWorkspace : (Get-PbiFabWorkspaceId -WorkspaceName $SourceWorkspace)
  # If $DestinationWorkspace is not a GUID, assume it is a workspace name and retrieve the workspace ID.
  $destinationWorkspaceId = $DestinationWorkspace -match $guidMatch ? $DestinationWorkspace : (Get-PbiFabWorkspaceId -WorkspaceName $DestinationWorkspace)
}

process {
  # Retrieve a list of all notebooks in the source workspace.
  $notebooksList = (Invoke-RestMethod -Method GET -Uri "$fabricUri/$sourceWorkspaceId/notebooks" -Headers $headers).value
  # If Notebooks parameter is left blank, list all notebooks in the source workspace and prompt the user to select one or more of them.
  if (-not $Notebooks) {
    $selectedNotebooks = $notebooksList | Out-ConsoleGridView -Title 'Select notebook(s) to copy'
    Write-Host $selectedNotebooks
  }
  else {
    foreach ($notebook in $Notebooks) {
      $selectedNotebooks += $notebooksList | Where-Object { $notebook -in $_.displayName, $_.id }
    }
    Write-Host $selectedNotebooks
  }
  # Copy each notebook to the destination workspace.
  foreach ($notebook in $selectedNotebooks) {
    $notebookId = $notebook.Id
    $notebookName = $notebook.Name
    $notebookDescription = $notebook.Description
    try {
      $notebookDefinition = (Invoke-RestMethod -Method POST -Uri "$fabricUri/$sourceWorkspaceId/notebooks/$notebookId/getDefinition" -Headers $headers).value
      $notebookDefinition | Add-Member -MemberType NoteProperty -Name 'displayName' -Value $notebookName
      $notebookDefinition | Add-Member -MemberType NoteProperty -Name 'description' -Value $notebookDescription
      $requestBody = $notebookDefinition | ConvertTo-Json -Depth 100
      $response = Invoke-RestMethod -Method POST -Uri "$fabricUri/$destinationWorkspaceId/notebooks" -Headers $headers -Body $requestBody
      Write-Host $response
      Write-Host "📋 Notebook '$notebookName' (ID: $notebookId) copied successfully."
    }
    catch {
      Write-Error "❌ Error copying notebook '$notebookName' (ID: $notebookId)."
    }
  }
}