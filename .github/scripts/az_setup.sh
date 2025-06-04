#!/bin/bash
set -e

# --- Configuration ---
RESOURCE_GROUP="${RESOURCE_GROUP:-azappsvc-rg}"
LOCATION="${LOCATION:-australiaeast}"
SP_NAME="${SP_NAME:-azappsvc-sp}"
REPO_FULL="${REPO_FULL:-}"

# --- Validate required input ---
if [[ -z "$REPO_FULL" ]]; then
  echo "❌ Missing required environment variable: REPO_FULL."
  exit 1
fi

# --- Retrieve Subscription ID ---
if [[ -z "$SUBSCRIPTION_ID" ]]; then
  echo "📡 No SUBSCRIPTION_ID provided. Attempting to retrieve from Azure context..."
  export SUBSCRIPTION_ID=$(az account show --query id -o tsv 2>/dev/null || true)
  if [[ -z "$SUBSCRIPTION_ID" ]]; then
    echo "❌ Unable to detect active subscription. Please run 'az login' or set SUBSCRIPTION_ID."
    exit 1
  fi
fi

# --- Set context and get tenant ID ---
az account set --subscription "$SUBSCRIPTION_ID"
export TENANT_ID=$(az account show --query tenantId -o tsv)

# --- Create Resource Group ---
if ! az group show --name "$RESOURCE_GROUP" --subscription "$SUBSCRIPTION_ID" &>/dev/null; then
  echo "📦 Creating resource group '$RESOURCE_GROUP'..."
  az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --subscription "$SUBSCRIPTION_ID" \
    --output none
  echo "✅ Resource group created."
else
  echo "✅ Resource group '$RESOURCE_GROUP' already exists."
fi

# --- Create or reuse service principal ---
echo "🔍 Checking if service principal '$SP_NAME' exists..."
export APP_ID=$(az ad sp list --display-name "$SP_NAME" --query "[0].appId" -o tsv || true)

if [[ -z "$APP_ID" ]]; then
  echo "🔐 Creating new service principal..."
  APP_ID=$(az ad sp create --id "$(az ad app create --display-name "$SP_NAME" --query appId -o tsv)" --query appId -o tsv)
else
  echo "✅ Service principal already exists: $APP_ID"
fi

export SP_APP_ID="$APP_ID"

# --- Generate client secret ---
echo "🔐 Generating client secret..."
export CLIENT_SECRET=$(az ad app credential reset --id "$APP_ID" --append --query password -o tsv)

# --- Role assignment skipped ---
echo "⚠️ Skipping automatic role assignment (requires Owner/User Access Admin)."
echo "👉 Please assign Contributor manually:"
echo "   az role assignment create --assignee \"$APP_ID\" --role Contributor --scope \"/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP\""

# --- Construct Azure credentials object ---
AZURE_CREDENTIALS=$(cat <<EOF
{
  "clientId": "$APP_ID",
  "clientSecret": "$CLIENT_SECRET",
  "subscriptionId": "$SUBSCRIPTION_ID",
  "tenantId": "$TENANT_ID",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
EOF
)

# --- Save secrets to GitHub ---
echo "🔐 Saving secrets to GitHub repository '$REPO_FULL'..."
gh secret set AZURE_CREDENTIALS --body "$AZURE_CREDENTIALS" --repo "$REPO_FULL"
gh secret set RESOURCE_GROUP --body "$RESOURCE_GROUP" --repo "$REPO_FULL"
gh secret set LOCATION --body "$LOCATION" --repo "$REPO_FULL"
gh secret set SUBSCRIPTION_ID --body "$SUBSCRIPTION_ID" --repo "$REPO_FULL"
gh secret set SP_NAME --body "$SP_NAME" --repo "$REPO_FULL"
gh secret set SP_APP_ID --body "$SP_APP_ID" --repo "$REPO_FULL"

echo "✅ Done. All environment variables exported and GitHub secrets updated."

# --- Print for chaining/debugging ---
echo ""
echo "🔄 Export these for subsequent scripts:"
echo "export RESOURCE_GROUP=$RESOURCE_GROUP"
echo "export LOCATION=$LOCATION"
echo "export SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
echo "export TENANT_ID=$TENANT_ID"
echo "export SP_APP_ID=$SP_APP_ID"
echo "export CLIENT_SECRET=<hidden>"
