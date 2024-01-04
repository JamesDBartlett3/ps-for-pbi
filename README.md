# PowerShell for Power BI

## Introduction
This repository contains PowerShell scripts that can be used to streamline and automate tasks in Power BI.

## Prerequisites
- Any necessary permissions for the tasks you want to perform (e.g. Power BI tenant admin, workspace admin, etc.)
- [PowerShell (version 7+ required for some scripts)](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1)
- PowerShell modules (all are required by one or more scripts, but none are required by all)
  - [MicrosoftPowerBIMgmt module](https://www.powershellgallery.com/packages/MicrosoftPowerBIMgmt)
  - [ImportExcel module](https://www.powershellgallery.com/packages/ImportExcel)
  - [DataGateway module](https://www.powershellgallery.com/packages/DataGateway)
  - [Microsoft.PowerShell.ConsoleGuiTools module](https://www.powershellgallery.com/packages/Microsoft.PowerShell.ConsoleGuiTools)

## Usage
1. Open PowerShell (`pwsh`)
2. Install any PowerShell modules required by the script(s) you want to run (e.g. `Install-Module -Name MicrosoftPowerBIMgmt, DataGateway -Scope CurrentUser`)
3. Allow PowerShell to run scripts downloaded from the Internet (`Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser`)
4. Clone this repository (`git clone https://github.com/JamesDBartlett3/ps-for-pbi.git C:\Users\{your-username}\GitHub\ps-for-pbi`)
5. Navigate to the folder where you cloned this repository (`cd C:\Users\{your-username}\GitHub\ps-for-pbi\`)
6. Unblock the scripts to make them executable on your system (`Unblock-File -Path .\*.ps1`)
7. Run the script you want to use (e.g. `.\Export-PowerBIScannerApiData.ps1`)

## Scripts

### Admin, Governance, and Security
- [Export-PowerBIScannerApiData.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Export-PowerBIScannerApiData.ps1): Exports data from the [Power BI Scanner API](https://learn.microsoft.com/en-us/power-bi/enterprise/service-admin-metadata-scanning) to a .json file
- [Checkpoint-PowerBIWorkspaceSecurity.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Checkpoint-PowerBIWorkspaceSecurity.ps1): Saves the current security settings of all Power BI workspaces to which the user has access as an .xlsx file
- [Get-DataGatewayStatus.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Get-DataGatewayStatus.ps1): Retrieves the status of all nodes in all Data Gateway clusters to which the user has access

### Reports
- [Copy-PowerBIReportContentToBlankPBIXFile.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Copy-PowerBIReportContentToBlankPBIXFile.ps1): Copies the content of a published Power BI report to a blank .pbix file, then downloads it (useful for downloading reports that cannot be downloaded from the Power BI service by conventional means)
- [Export-PowerBIReportsFromWorkspaces.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Export-PowerBIReportsFromWorkspaces.ps1): Exports all Power BI reports (.pbix and .rdl files) from all workspaces specified by the user, saves them in folders named after the workspaces they came from, and optionally extracts the .pbix files' source code using [pbi-tools](https://pbi.tools)
  
### Thin Models (Power BI semantic models without a corresponding report of the same name in the same workspace)
- [Get-PowerBIThinModelsFromWorkspaces.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Get-PowerBIThinModelsFromWorkspaces.ps1): Finds all Thin Models to which the user has access and outputs the results as a PSObject with the following properties: 
  - DatasetName
  - DatasetId
  - WorkspaceName
  - WorkspaceId
  - WebUrl
  - IsRefreshable
- [Export-PowerBIThinModelsFromWorkspaces.ps1](https://github.com/JamesDBartlett3/ps-for-pbi/blob/main/Export-PowerBIThinModelsFromWorkspaces.ps1): Exports all Thin Models specified by the user (as parameters or piped input), and saves them in folders named after the workspaces they came from. (TODO: Add ExportWithPbiTools switch parameter)