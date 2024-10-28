param (
    [string]$subscription
)

if (-not $subscription) {
    Write-Host "Subscription ID is required. Use -subscription to provide it."
    exit 1
}

Write-Host "############################################################"
Write-Host "#    This script was generated using GitHub Copilot        #"
Write-Host "############################################################"
$confirmation = Read-Host "Have you read the script? (Y/N)"
if ($confirmation -ne "Y" -and $confirmation -ne "y" -and $confirmation -ne "yes") {
    Write-Host "Please read the script before proceeding."
    exit 1
}

# Get the current terminal username
$current_user = $env:USERNAME
Write-Host " - Current terminal username is $current_user"

$AZURE_OPENAI_LOCATION = "eastus"
$SESSION_POOL_LOCATION = "eastus"

$RESOURCE_GROUP_NAME = "$current_user-code-interpreter-rg"
$AZURE_OPENAI_NAME = "$current_user-openai"
$SESSION_POOL_NAME = "$current_user-code-interpreter-pool"

az account set --subscription $subscription
Write-Host " - Successfully set the subscription to $subscription"

# Remove container apps extension
az extension remove --name containerapp
Write-Host " - Successfully removed the container apps extension"

# Add container apps extension
az extension add --name containerapp --allow-preview true -y
Write-Host " - Successfully added the container apps extension"

az login

az group create --name $RESOURCE_GROUP_NAME --location $SESSION_POOL_LOCATION
Write-Host " - Successfully created the resource group $RESOURCE_GROUP_NAME in $SESSION_POOL_LOCATION"

# Create an Azure OpenAI account
az cognitiveservices account create `
    --name $AZURE_OPENAI_NAME `
    --resource-group $RESOURCE_GROUP_NAME `
    --location $AZURE_OPENAI_LOCATION `
    --kind OpenAI `
    --sku s0 `
    --custom-domain $AZURE_OPENAI_NAME

Write-Host " - Successfully created the Azure OpenAI account $AZURE_OPENAI_NAME in $RESOURCE_GROUP_NAME"

# Create a GPT 4 Turbo model deployment
az cognitiveservices account deployment create `
    --resource-group $RESOURCE_GROUP_NAME `
    --name $AZURE_OPENAI_NAME `
    --deployment-name gpt-4 `
    --model-name gpt-4 `
    --model-version "turbo-2024-04-09" `
    --model-format OpenAI `
    --sku-capacity "100" `
    --sku-name "Standard"

Write-Host " - Successfully created the GPT 4 Turbo model deployment in the Azure OpenAI account $AZURE_OPENAI_NAME"

# Create a code interpreter session pool
az containerapp sessionpool create `
    --name $SESSION_POOL_NAME `
    --resource-group $RESOURCE_GROUP_NAME `
    --location $SESSION_POOL_LOCATION `
    --max-sessions 100 `
    --container-type PythonLTS `
    --cooldown-period 300

Write-Host " - Successfully created the code interpreter session pool $SESSION_POOL_NAME in $RESOURCE_GROUP_NAME"