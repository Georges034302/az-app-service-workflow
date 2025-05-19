#!/bin/bash
set -e

# --- Load from environment ---
APP_NAME="${APP_NAME:-}"
RESOURCE_GROUP="${RESOURCE_GROUP:-}"
ACR_NAME="${ACR_NAME:-}"
REPO_FULL="${REPO_FULL:-}"

# --- Set APP_NAME if not predefined ---
if [[ -z "$APP_NAME" ]]; then
  APP_NAME="appsvc-$(openssl rand -hex 3)"
  echo "ℹ️  APP_NAME was not set. Generated: $APP_NAME"
fi

# --- Validate other required vars ---
if [[ -z "$RESOURCE_GROUP" || -z "$ACR_NAME" || -z "$REPO_FULL" ]]; then
  echo "❌ Missing required inputs: RESOURCE_GROUP, ACR_NAME, or REPO_FULL"
  exit 1
fi

echo "⚙️ Configuring Web App '$APP_NAME' in resource group '$RESOURCE_GROUP' to use container image from ACR '$ACR_NAME'..."

az webapp config container set \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --docker-custom-image-name "$ACR_NAME.azurecr.io/employee-api:latest" \
  --docker-registry-server-url "https://$ACR_NAME.azurecr.io"

echo "🔐 Saving APP_NAME to GitHub secrets..."
gh secret set APP_NAME --body "$APP_NAME" --repo "$REPO_FULL"

echo "✅ Web App container configured for $APP_NAME"
