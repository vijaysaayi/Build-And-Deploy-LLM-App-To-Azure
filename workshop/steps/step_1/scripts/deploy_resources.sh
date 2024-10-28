
#!/bin/bash

# set the subscription
while getopts s: flag
do
    case "${flag}" in
        s) subscription=${OPTARG};;
    esac
done

if [ -z "$subscription" ]; then
    echo "Subscription ID is required. Use -s to provide it."
    exit 1
fi

# Get the current terminal username
current_user=$(whoami)
echo " - Current terminal username is $current_user"

AZURE_OPENAI_LOCATION=eastus
SESSION_POOL_LOCATION=eastus

RESOURCE_GROUP_NAME=${current_user}-code-interpreter-rg
AZURE_OPENAI_NAME=${current_user}openai
SESSION_POOL_NAME=${current_user}-code-interpreter-pool

az account set --subscription $subscription
echo " - Successfully set the subscription to $subscription"

# remove container apps extension
az extension remove --name containerapp
echo " - Successfully removed the container apps extension"

# add container apps extension
az extension add \
    --name containerapp \
    --allow-preview true -y
echo " - Successfully added the container apps extension"

az login

az group create --name $RESOURCE_GROUP_NAME --location $SESSION_POOL_LOCATION
echo " - Successfully created the resource group $RESOURCE_GROUP_NAME in $SESSION_POOL_LOCATION"

# Create an Azure OpenAI account:
az cognitiveservices account create \
    --name $AZURE_OPENAI_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --location $AZURE_OPENAI_LOCATION \
    --kind OpenAI \
    --sku s0 \
    --custom-domain $AZURE_OPENAI_NAME

echo " - Successfully created the Azure OpenAI account $AZURE_OPENAI_NAME in $RESOURCE_GROUP_NAME"

# Create a GPT 4 Turbo model deployment named gpt-35-turbo in the Azure OpenAI account:
az cognitiveservices account deployment create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $AZURE_OPENAI_NAME \
    --deployment-name gpt-4 \
    --model-name gpt-4 \
    --model-version "turbo-2024-04-09" \
    --model-format OpenAI \
    --sku-capacity "100" \
    --sku-name "Standard"

echo " - Successfully created the GPT 4 Turbo model deployment in the Azure OpenAI account $AZURE_OPENAI_NAME"

# Create a code interpreter session pool:
az containerapp sessionpool create \
    --name $SESSION_POOL_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --location $SESSION_POOL_LOCATION \
    --max-sessions 100 \
    --container-type PythonLTS \
    --cooldown-period 300

echo " - Successfully created the code interpreter session pool $SESSION_POOL_NAME in $RESOURCE_GROUP_NAME"