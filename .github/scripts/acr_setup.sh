#!/bin/bash
set -e

# --- Hardcoded configuration ---
RESOURCE_GROUP="azappsvc-rg"
LOCATION="australiaeast"
REPO_FULL="${REPO_FULL:-}"
SP_APP_ID="${SP_APP_ID:-}"
OWNER="${OWNER:-}"
APP_NAME="${APP_NAME:-employee-api-appsvc}"

# --- Validate inputs ---
if [[ -z "$REPO_FULL" || -z "$SP_APP_ID" || -z "$OWNER" ]]; then
  echo "❌ Missing one of: REPO_FULL, SP_APP_ID, OWNER"
  exit 1
fi

# --- Ensure subscription context is set ---
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

echo "📘 Using subscription: $SUBSCRIPTION_ID"
echo "📘 Using tenant: $TENANT_ID"

az account set --subscription "$SUBSCRIPTION_ID"

# --- Compute ACR name ---
CLEAN_OWNER=$(echo "$OWNER" | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]')
ACR_NAME="az${CLEAN_OWNER}acr"
ACR_NAME="${ACR_NAME:0:50}"
echo "🔧 Using ACR name: $ACR_NAME"

# --- Create ACR ---
echo "🔍 Checking if ACR '$ACR_NAME' exists..."
if az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --subscription "$SUBSCRIPTION_ID" &>/dev/null; then
  echo "✅ ACR '$ACR_NAME' already exists."
else
  echo "📦 Creating ACR '$ACR_NAME'..."
  az acr create \
    --name "$ACR_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --sku Basic \
    --location "$LOCATION" \
    --admin-enabled true \
    --subscription "$SUBSCRIPTION_ID" \
    --only-show-errors \
    --output none
  echo "✅ ACR created."
fi

# --- Fetch credentials ---
echo "🔑 Fetching ACR credentials..."
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --subscription "$SUBSCRIPTION_ID" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --subscription "$SUBSCRIPTION_ID" --query "passwords[0].value" -o tsv)
ACR_ID=$(az acr show --name "$ACR_NAME" --subscription "$SUBSCRIPTION_ID" --query id -o tsv)

# --- Assign role ---
echo "🔗 Assigning 'AcrPush' role..."
az role assignment create \
  --assignee "$SP_APP_ID" \
  --role "AcrPush" \
  --scope "$ACR_ID" \
  --subscription "$SUBSCRIPTION_ID" \
  --output none || true
echo "✅ 'AcrPush' role assigned."

# --- Save to GitHub secrets ---
echo "💾 Saving secrets to GitHub..."
gh secret set ACR_NAME --body "$ACR_NAME" --repo "$REPO_FULL"
gh secret set ACR_USERNAME --body "$ACR_USERNAME" --repo "$REPO_FULL"
gh secret set ACR_PASSWORD --body "$ACR_PASSWORD" --repo "$REPO_FULL"
gh secret set APP_NAME --body "$APP_NAME" --repo "$REPO_FULL"

echo "============================================================"
echo "✅ ACR setup complete and all GitHub secrets saved."

