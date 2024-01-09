# Export Power BI Scanner API data to a JSON file, then open it
.\Checkpoint-PowerBIScannerApiData.ps1 -OpenFile

# Export security settings for all Power BI Workspaces to an Excel file, then open it
.\Checkpoint-PowerBIWorkspaceSecurity.ps1 -OpenFile

# Export usage metrics for a Power BI Workspace to a CSV file, then open it
.\Checkpoint-WorkspaceUsageMetrics.ps1 -OpenFile `
	-WorkspaceID 12398b8b-568b-4191-8af3-968475609e40

# Create one or more copies of a Goal on a Power BI Scorecard
# This is useful for quickly creating multiple Goals that are similar to an existing one
.\Copy-GoalInScoreCard.ps1

# Copy the content of a Power BI Report to a blank PBIX file, then download that file
# This is useful for downloading a report that was authored in a personal workspace,
# or is otherwise not available for download
.\Copy-PowerBIReportContentToBlankPBIXFile.ps1 `
	-SourceReportId `
	-SourceWorkspaceId

# Rebind a Power BI Report to a different dataset
.\Update-PowerBIReportDatasetBinding.ps1 `
	-TargetDatasetID c542b17f-e941-45b4-938f-c70545abb9b3 `
	-ReportWorkspaceID 80500cbf-25ce-4b64-b191-5273c111d617 `
	-ReportID 7f96ade7-7875-48bd-a112-5d9e0feaf869

# Now change it back
.\Update-PowerBIReportDatasetBinding.ps1 `
	-TargetDatasetID 273fc7bc-703d-4106-b591-5f89a32420a8 `
	-ReportWorkspaceID 80500cbf-25ce-4b64-b191-5273c111d617 `
	-ReportID 7f96ade7-7875-48bd-a112-5d9e0feaf869

# Export Power BI Reports from Workspaces, and extract their source code with PBI-Tools
.\Export-PowerBIReportsFromWorkspaces.ps1 -ExtractWithPbiTools

# Get a list of Thin Models from selected Workspaces, and export them to a temp folder
.\Get-PowerBIThinModelsFromWorkspaces.ps1 -Interactive | .\Export-PowerBIThinModelsFromWorkspaces.ps1

# Get the status of all Data Gateway nodes to which the current user has access
.\Get-DataGatewayStatus.ps1