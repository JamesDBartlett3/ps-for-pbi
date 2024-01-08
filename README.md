# Table of Contents
- [Table of Contents](#table-of-contents)
- [Authors](#authors)
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Scripts](#scripts)
  - [Admin, Governance, and Security](#admin-governance-and-security)
  - [Canvas (.pbix) and Paginated (.rdl) Reports](#canvas-pbix-and-paginated-rdl-reports)
  - [Thin Models _(Power BI semantic models without a corresponding report of the same name in the same workspace)_](#thin-models-power-bi-semantic-models-without-a-corresponding-report-of-the-same-name-in-the-same-workspace)

# Authors
- James D. Bartlett III [[Blog (DataVolume.xyz)](https://datavolume.xyz), [GitHub](https://github.com/JamesDBartlett3), [LinkedIn](https://www.linkedin.com/in/jamesdbartlett3/), [Mastodon](https://techhub.social/@JamesDBartlett3), [Bluesky](https://bsky.app/profile/jamesdbartlett3.bsky.social)]
- Štěpán Rešl [[Blog (DataMeerkat.com)](https://datameerkat.com), [GitHub](https://github.com/tirnovar), [LinkedIn](https://www.linkedin.com/in/stepan-resl/), [Mastodon](https://techhub.social/@StepanResl), [Bluesky](https://bsky.app/profile/stepanresl.bsky.social), [X / Twitter](https://twitter.com/tpnRel1)]

# Introduction
This repository contains PowerShell scripts that can be used to streamline and automate tasks in Power BI.

# Prerequisites
- Any necessary permissions for the tasks you want to perform (e.g. Power BI tenant admin, workspace admin, etc.)
- [PowerShell (version 7+ required for some scripts)](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1)
- PowerShell modules (all are required by one or more scripts, but none are required by all)
  - [MicrosoftPowerBIMgmt](https://www.powershellgallery.com/packages/MicrosoftPowerBIMgmt)
  - [ImportExcel](https://www.powershellgallery.com/packages/ImportExcel)
  - [DataGateway](https://www.powershellgallery.com/packages/DataGateway)
  - [Microsoft.PowerShell.ConsoleGuiTools](https://www.powershellgallery.com/packages/Microsoft.PowerShell.ConsoleGuiTools)

# Usage

1. Open PowerShell (`pwsh`)
2. Install any PowerShell modules required by the script(s) you want to run, e.g.:  
`Install-Module -Name MicrosoftPowerBIMgmt, ImportExcel, DataGateway, Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser`
3. Allow PowerShell to run scripts downloaded from the Internet  
`Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser`
1. Clone this repository, e.g.:  
`git clone https://github.com/JamesDBartlett3/ps-for-pbi ~\GitHub\ps-for-pbi`
1. Navigate to the folder where you cloned this repository, e.g.:  
`cd ~\GitHub\ps-for-pbi\`
1. Unblock the scripts to make them executable on your system  
`Unblock-File -Path .\*.ps1`
1. Run the script you want to use, e.g.:  
`.\Export-PowerBIScannerApiData.ps1`

# Scripts

## Admin, Governance, and Security
- [Checkpoint-PowerBIScannerApiData.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Checkpoint-PowerBIScannerApiData.ps1)
  - Exports data from the [Power BI Scanner API](https://learn.microsoft.com/en-us/power-bi/enterprise/service-admin-metadata-scanning) to a timestamped .json file
  - TODO: Add support for exporting to .csv & .xlsx
- [Checkpoint-PowerBIWorkspaceSecurity.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Checkpoint-PowerBIWorkspaceSecurity.ps1)
  - Exports the current security settings of all Power BI workspaces to which the user has access to a timestamped .xlsx file
  - TODO: Add support for exporting to .json & .csv
- [Get-DataGatewayStatus.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Get-DataGatewayStatus.ps1)
  - Retrieves the status of all nodes in all Data Gateway clusters to which the user has access
- [Update-PowerBIReportDatasetBinding.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Update-PowerBIReportDatasetBinding.ps1)
  - Change connection of report to the specified semantic model

## Canvas (.pbix) and Paginated (.rdl) Reports
- [Copy-PowerBIReportContentToBlankPBIXFile.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Copy-PowerBIReportContentToBlankPBIXFile.ps1)
  - Copies the content of a published Power BI canvas report to a blank .pbix file, then downloads it 
  - Useful for downloading reports that cannot be downloaded from the Power BI service by conventional means for any number of reasons (e.g. the report was authored in a personal workspace, the semantic model was modified by XMLA endpoint, etc.)
- [Export-PowerBIReportsFromWorkspaces.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Export-PowerBIReportsFromWorkspaces.ps1)
  - Exports all Power BI canvas (.pbix) and paginated (.rdl) reports from all workspaces specified by the user, saves them in folders named after the workspaces they came from, and optionally extracts the .pbix files' source code using [pbi-tools](https://pbi.tools)
  - TODO: Add support for exporting canvas reports as .pbip files (pending future support in either [pbi-tools](https://pbi.tools) or the [Power BI REST API](https://learn.microsoft.com/en-us/rest/api/power-bi/))

## Thin Models _(Power BI semantic models without a corresponding report of the same name in the same workspace)_
- [Get-PowerBIThinModelsFromWorkspaces.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Get-PowerBIThinModelsFromWorkspaces.ps1)
  - Finds all Thin Models to which the user has access and outputs the results as a PSObject with the following properties: 
    - DatasetName
    - DatasetId
    - WorkspaceName
    - WorkspaceId
    - WebUrl
    - IsRefreshable
- [Export-PowerBIThinModelsFromWorkspaces.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Export-PowerBIThinModelsFromWorkspaces.ps1)
  - Exports all Thin Models specified by the user (as parameter values or piped input), and saves them in folders named after the workspaces they came from
  - TODO: Add `ExportWithPbiTools` switch parameter

## Usage Metrics _(It doesn't require Admin permission. You need to be the content owner.)_
- [Get-UsageMetricsDataset.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Get-UsageMetricsDataset.ps1)
  - Return the ID of the hidden Usage Metric Semantic Model in the specified workspace; if that semantic model doesn't exist, it will create it.
  - TODO: Add DAX queries to download data from this dataset for further analysis.

## Scorecards
- [Copy-GoalInScoreCard.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Copy-GoalToScoreCard.ps1)
  - Duplicate a goal in scorecards. It can create as many duplicates of same goal as needed.
