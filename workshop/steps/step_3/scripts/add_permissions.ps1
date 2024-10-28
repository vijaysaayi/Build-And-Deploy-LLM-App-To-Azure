param (
    [string]$AZURE_OPENAI_NAME,
    [string]$RESOURCE_GROUP_NAME,
    [string]$SESSION_POOL_NAME,
    [string]$SUBSCRIPTION_NAME
)

if (-not $AZURE_OPENAI_NAME -or -not $RESOURCE_GROUP_NAME -or -not $SESSION_POOL_NAME -or -not $SUBSCRIPTION_NAME) {
    Write-Host "Usage: .\add_permissions.ps1 -AZURE_OPENAI_NAME <AZURE_OPENAI_NAME> -RESOURCE_GROUP_NAME <RESOURCE_GROUP_NAME> -SESSION_POOL_NAME <SESSION_POOL_NAME> -SUBSCRIPTION_NAME <SUBSCRIPTION_NAME>"
    exit 1
}

Write-Host "############################################################"
Write-Host "#     This script was generated by GitHub Copilot.         #"
Write-Host "#     Please review the script before executing.           #"
Write-Host "############################################################"
$confirmation = Read-Host "Do you want to proceed with the script execution? (Y/y/yes to proceed)"

if ($confirmation -match '^(yes|y|Y)$') {
    az account set --subscription $SUBSCRIPTION_NAME

    $alias = az account show --query user.name --output tsv
    $azureopenai_scope = az cognitiveservices account show --name $AZURE_OPENAI_NAME --resource-group $RESOURCE_GROUP_NAME --query id --output tsv
    az role assignment create --role "Cognitive Services OpenAI User" --assignee $alias --scope $azureopenai_scope

    $session_pool_scope = az containerapp sessionpool show --name $SESSION_POOL_NAME --resource-group $RESOURCE_GROUP_NAME --query id --output tsv
    az role assignment create `
        --role "Azure ContainerApps Session Executor" `
        --assignee $alias `
        --scope $session_pool_scope
} else {
    Write-Host "Script execution aborted."
    exit 0
}