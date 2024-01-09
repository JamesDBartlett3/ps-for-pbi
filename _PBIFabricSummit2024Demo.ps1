# Checkpoint-PowerBIScannerApiData.ps1
.\Checkpoint-PowerBIScannerApiData.ps1 -OpenFile

# Checkpoint-PowerBIWorkspaceSecurity.ps1
.\Checkpoint-PowerBIWorkspaceSecurity.ps1

# Checkpoint-WorkspaceUsageMetrics.ps1
.\Checkpoint-WorkspaceUsageMetrics.ps1 `
	-WorkspaceID d0064e4a-6365-44db-8236-ba2c7d5c198b

# Copy-GoalInScorecard.ps1
.\Copy-GoalInScoreCard.ps1

# Copy-PowerBIReportContentToBlankPBIXFile.ps1
.\Copy-PowerBIReportContentToBlankPBIXFile.ps1 `
	-SourceReportId  `
	-SourceWorkspaceId 

# Update-PowerBIReportDatasetBinding.ps1
.\Update-PowerBIReportDatasetBinding.ps1 `
	-TargetDatasetID c542b17f-e941-45b4-938f-c70545abb9b3 `
	-ReportWorkspaceID 80500cbf-25ce-4b64-b191-5273c111d617 `
	-ReportID 7f96ade7-7875-48bd-a112-5d9e0feaf869

# Working with Reports and Models
.\Export-PowerBIReportsFromWorkspaces.ps1 `
	-ExtractWithPbiTools `
	-SkipExistingFiles `
	-ThrottleLimit 4

.\Update-PowerBIReportDatasetBinding.ps1

# Thin Models
.\Get-PowerBIThinModelsFromWorkspaces.ps1 -Interactive | .\Export-PowerBIThinModelsFromWorkspaces.ps1