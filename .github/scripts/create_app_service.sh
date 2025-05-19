#!/bin/bash
set -e

# === Validate required inputs ===
if [[ -z "$APP_NAME" || -z "$RESOURCE_GROUP" || -z "$ACR_NAME" ]]; then
  echo "❌ Missing APP_NAME, RESOURCE_GROUP, or ACR_NAME."
  exit 1
fi

echo "🔑 Logging in to ACR '$ACR_NAME'..."
az acr login --name "$ACR_NAME"

echo "🛠️ Building Docker image..."
docker build -t "$ACR_NAME.azurecr.io/employee-api:latest" .

echo "📤 Pushing Docker image to ACR..."
docker push "$ACR_NAME.azurecr.io/employee-api:latest"

# === Ensure App Service Plan exists ===
PLAN_NAME="${APP_NAME}-plan"
if az appservice plan show --name "$PLAN_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
  echo "✅ App Service plan '$PLAN_NAME' exists."
else
  echo "🖥️ Creating App Service plan..."
  az appservice plan create \
    --name "$PLAN_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --is-linux \
    --sku B1 \
    --output none
fi

# === Ensure Web App exists ===
if az webapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
  echo "✅ Web App '$APP_NAME' exists."
else
  echo "🚀 Creating Web App '$APP_NAME'..."
  az webapp create \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --plan "$PLAN_NAME" \
    --deployment-container-image-name "$ACR_NAME.azurecr.io/employee-api:latest" \
    --output none
fi

echo "✅ Web App '$APP_NAME' deployed successfully."
echo "=============================================="