#!/bin/bash
set -e

APP_NAME="${APP_NAME:-}"
RESOURCE_GROUP="${RESOURCE_GROUP:-}"
ACR_NAME="${ACR_NAME:-}"
REPO_FULL="${REPO_FULL:-}"

# --- Validate inputs ---
if [[ -z "$APP_NAME" || -z "$RESOURCE_GROUP" || -z "$ACR_NAME" || -z "$REPO_FULL" ]]; then
  echo "❌ Missing required inputs: APP_NAME, RESOURCE_GROUP, ACR_NAME, or REPO_FULL"
  exit 1
fi

# --- Check if Web App exists ---
echo "🔍 Checking if Web App '$APP_NAME' exists in resource group '$RESOURCE_GROUP'..."
if ! az webapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
  echo "❌ Web App '$APP_NAME' not found in resource group '$RESOURCE_GROUP'."
  echo "➡️  You must create it before running this script."
  exit 1
fi

# --- Apply container config ---
# Step 5: Apply container configuration
echo "⚙️ Configuring Web App '$APP_NAME' to use image from ACR '$ACR_NAME'..."
az webapp config container set \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --docker-custom-image-name "$ACR_NAME.azurecr.io/employee-api:latest" \
  --docker-registry-server-url "https://$ACR_NAME.azurecr.io"