#!/bin/bash
set -e

# === Static/expected variables ===
RESOURCE_GROUP="azappsvc-rg"
LOCATION="australiaeast"
SP_NAME="azappsvc-sp"

# === Validate required inputs ===
if [[ -z "$SUBSCRIPTION_ID" || -z "$REPO_FULL" ]]; then
  echo "❌ Missing required environment variables: SUBSCRIPTION_ID or REPO_FULL."
  exit 1
fi

# === Resource Group ===
echo "📦 Checking if resource group '$RESOURCE_GROUP' exists in '$LOCATION'..."
if az group show --name "$RESOURCE_GROUP" &>/dev/null; then
  echo "✅ Resource group '$RESOURCE_GROUP' already exists."
else
  echo "📦 Creating resource group '$RESOURCE_GROUP' in '$LOCATION'..."
  az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
  echo "✅ Resource group created."
fi

# === Create Service Principal and extract credentials ===
echo "🔐 Creating Azure service principal '$SP_NAME' for subscription '$SUBSCRIPTION_ID'..."
AZURE_CREDENTIALS=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role contributor \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --query "{clientId: appId, clientSecret: password, tenantId: tenant, subscriptionId: '$SUBSCRIPTION_ID'}" \
  --output json)

# === Save to temp file for later use if needed ===
echo "$AZURE_CREDENTIALS" > creds.json

# === Extract client ID for role assignments ===
SP_APP_ID=$(echo "$AZURE_CREDENTIALS" | jq -r '.clientId')

# === Set GitHub secrets ===
echo "🔑 Saving secrets to GitHub repository '$REPO_FULL'..."
gh secret set AZURE_CREDENTIALS --body "$AZURE_CREDENTIALS" --repo "$REPO_FULL"
gh secret set RESOURCE_GROUP --body "$RESOURCE_GROUP" --repo "$REPO_FULL"
gh secret set SUBSCRIPTION_ID --body "$SUBSCRIPTION_ID" --repo "$REPO_FULL"
gh secret set LOCATION --body "$LOCATION" --repo "$REPO_FULL"
gh secret set SP_NAME --body "$SP_NAME" --repo "$REPO_FULL"
gh secret set SP_APP_ID --body "$SP_APP_ID" --repo "$REPO_FULL"

# === Azure AD propagation wait ===
echo "⏳ Waiting for Azure AD propagation before login/role assignments..."
sleep 60

echo "✅ Azure service principal created and secrets saved to GitHub."
