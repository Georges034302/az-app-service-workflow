#!/bin/bash
set -e

RESOURCE_GROUP="azappsvc-rg"
LOCATION="australiaeast"
SP_NAME="azappsvc-sp"

echo "📦 Checking if resource group '$RESOURCE_GROUP' exists in '$LOCATION'..."
if az group show --name "$RESOURCE_GROUP" &>/dev/null; then
  echo "✅ Resource group '$RESOURCE_GROUP' already exists."
else
  echo "📦 Creating resource group: $RESOURCE_GROUP in $LOCATION..."
  az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
  echo "✅ Resource group '$RESOURCE_GROUP' created."
fi

echo "🔐 Creating Azure service principal for RBAC (future-proof, no --sdk-auth)..."
AZURE_CREDENTIALS=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role contributor \
  --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP" \
  --query "{clientId: appId, clientSecret: password, tenantId: tenant, subscriptionId: '$SUBSCRIPTION_ID'}" \
  --output json)

echo "$AZURE_CREDENTIALS" > creds.json

az login \
  --service-principal \
  --username "$(jq -r .clientId creds.json)" \
  --password "$(jq -r .clientSecret creds.json)" \
  --tenant "$(jq -r .tenantId creds.json)"

echo "🔎 Extracting service principal appId..."
SP_APP_ID=$(echo "$AZURE_CREDENTIALS" | jq -r '.clientId')

echo "🔑 Saving secrets to GitHub repository..."
gh secret set AZURE_CREDENTIALS --body "$AZURE_CREDENTIALS" --repo "$REPO_FULL"
gh secret set RESOURCE_GROUP --body "$RESOURCE_GROUP" --repo "$REPO_FULL"
gh secret set SUBSCRIPTION_ID --body "$SUBSCRIPTION_ID" --repo "$REPO_FULL"
gh secret set LOCATION --body "$LOCATION" --repo "$REPO_FULL"
gh secret set SP_NAME --body "$SP_NAME" --repo "$REPO_FULL"
gh secret set SP_APP_ID --body "$SP_APP_ID" --repo "$REPO_FULL"

echo "✅ Azure login, resource group, and service principal setup complete."
