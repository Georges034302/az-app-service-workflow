#!/bin/bash
set -e

APP_NAME="app-service-$RANDOM"

echo "⚙️ Configuring Web App '$APP_NAME' in resource group '$RESOURCE_GROUP' to use container image from ACR '$ACR_NAME'..."

echo "🔧 Running: az webapp config container set --name \"$APP_NAME\" --resource-group \"$RESOURCE_GROUP\" --docker-custom-image-name \"$ACR_NAME.azurecr.io/employee-api:latest\" --docker-registry-server-url \"https://$ACR_NAME.azurecr.io\""
az webapp config container set \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --docker-custom-image-name "$ACR_NAME.azurecr.io/employee-api:latest" \
  --docker-registry-server-url "https://$ACR_NAME.azurecr.io"

echo "🔐 Saving APP_NAME to GitHub secrets..."
gh secret set APP_NAME --body "$APP_NAME" --repo "$REPO_FULL"

echo "✅ Web App container configured for $APP_NAME"
