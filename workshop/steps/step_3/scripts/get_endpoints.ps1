param (
    [string]$subscription,
    [string]$AZURE_OPENAI_NAME,
    [string]$RESOURCE_GROUP_NAME,
    [string]$SESSION_POOL_NAME
)

if (-not $subscription -or -not $AZURE_OPENAI_NAME -or -not $RESOURCE_GROUP_NAME -or -not $SESSION_POOL_NAME) {
    Write-Host "Usage: .\get_endpoints.ps1 -subscription <subscription> -AZURE_OPENAI_NAME <AZURE_OPENAI_NAME> -RESOURCE_GROUP_NAME <RESOURCE_GROUP_NAME> -SESSION_POOL_NAME <SESSION_POOL_NAME>"
    exit 1
}

Write-Host "##################################################"
Write-Host "# This script was generated using GitHub Copilot #"
Write-Host "##################################################"

$choice = Read-Host "Are you sure you want to proceed? (Y/y/yes): "
if ($choice -ne "Y" -and $choice -ne "y" -and $choice -ne "yes") {
    Write-Host "Operation cancelled."
    exit 1
}

az account set --subscription $subscription
Write-Host " - Successfully set the subscription to $subscription"

Write-Host "`n Add the result of the following commands to .env file in src/app folder"

# Show the cognitive services account endpoint
$endpoint = az cognitiveservices account show `
    --name $AZURE_OPENAI_NAME `
    --resource-group $RESOURCE_GROUP_NAME `
    --query properties.endpoint `
    --output tsv
Write-Host $endpoint

# Show the container app session pool management endpoint
$poolManagementEndpoint = az containerapp sessionpool show `
    --name $SESSION_POOL_NAME `
    --resource-group $RESOURCE_GROUP_NAME `
    --query properties.poolManagementEndpoint `
    --output tsv
Write-Host $poolManagementEndpoint
