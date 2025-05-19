#!/bin/bash
set -e

# === Load environment or use fallback defaults ===
RESOURCE_GROUP="${RESOURCE_GROUP:-azappsvc-rg}"
LOCATION="${LOCATION:-australiaeast}"
SP_NAME="${SP_NAME:-azappsvc-sp}"
SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-}"
REPO_FULL="${REPO_FULL:-}"

# === Validate required inputs ===
if [[ -z "$SUBSCRIPTION_ID" || -z "$REPO_FULL" ]]; then
  echo "❌ Missing required environment variables: SUBSCRIPTION_ID or REPO_FULL."
  exit 1
fi

echo "📘 Configuration:"
echo "   RESOURCE_GROUP: $RESOURCE_GROUP"
echo "   LOCATION:       $LOCATION"
echo "   SP_NAME:        $SP_NAME"

# === Resource Group Setup ===
echo "📦 Checking if resource group '$RESOURCE_GROUP' exists in '$LOCATION'..."
if az group show --name "$RESOURCE_GROUP" &>/dev/null; then
  echo "✅ Resource group '$RESOURCE_GROUP' already exists."
else
  echo "📦 Creating resource group '$RESOURCE_GROUP'..."
  az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
  echo "✅ Resource group created."
fi

# === Service Principal Creation ===
echo "🔐 Creating Azure service principal '$SP_NAME' scoped to subscription '$SUBSCRIPTION_ID'..."
AZURE_CREDENTIALS=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role contributor \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --sdk-auth)

# === Persist credentials (for optional debugging) ===
echo "$AZURE_CREDENTIALS" > creds.json

# === Extract App ID for role assignment later ===
SP_APP_ID=$(echo "$AZURE_CREDENTIALS" | jq -r '.clientId')

# === Save GitHub Secrets ===
echo "🔐 Saving secrets to GitHub repository '$REPO_FULL'..."
gh secret set AZURE_CREDENTIALS --body "$AZURE_CREDENTIALS" --repo "$REPO_FULL"
gh secret set RESOURCE_GROUP --body "$RESOURCE_GROUP" --repo "$REPO_FULL"
gh secret set SUBSCRIPTION_ID --body "$SUBSCRIPTION_ID" --repo "$REPO_FULL"
gh secret set LOCATION --body "$LOCATION" --repo "$REPO_FULL"
gh secret set SP_NAME --body "$SP_NAME" --repo "$REPO_FULL"
gh secret set SP_APP_ID --body "$SP_APP_ID" --repo "$REPO_FULL"

# === Wait for role propagation ===
echo "⏳ Waiting for Azure AD propagation..."
sleep 60

echo "✅ Azure service principal created and secrets saved successfully."
