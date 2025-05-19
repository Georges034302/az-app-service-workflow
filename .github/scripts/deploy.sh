#!/bin/bash
set -e

# === Validate required inputs ===
if [[ -z "$APP_NAME" || -z "$RESOURCE_GROUP" || -z "$ACR_NAME" ]]; then
  echo "❌ Missing required environment variables: APP_NAME, RESOURCE_GROUP, or ACR_NAME."
  echo "Ensure these are set in your GitHub Actions 'env:' block or secrets."
  exit 1
fi

echo "🔑 Logging in to Azure Container Registry '$ACR_NAME'..."
az acr login --name "$ACR_NAME"

echo "🛠️ Building Docker image for employee-api..."
docker build -t "$ACR_NAME.azurecr.io/employee-api:latest" .

echo "📤 Pushing Docker image to ACR..."
docker push "$ACR_NAME.azurecr.io/employee-api:latest"

# === Create App Service plan if not exists ===
PLAN_NAME="${APP_NAME}-plan"
echo "🧱 Checking App Service plan '$PLAN_NAME'..."
if az appservice plan show --name "$PLAN_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
  echo "✅ App Service plan already exists: $PLAN_NAME"
else
  echo "🖥️ Creating App Service plan '$PLAN_NAME' in resource group '$RESOURCE_GROUP'..."
  az appservice plan create \
    --name "$PLAN_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --is-linux \
    --sku B1
fi

# === Create Web App if not exists ===
echo "🌐 Checking if Web App '$APP_NAME' exists..."
if az webapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
  echo "✅ Web App '$APP_NAME' already exists."
else
  echo "🚀 Creating Web App '$APP_NAME'..."
  az webapp create \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --plan "$PLAN_NAME" \
    --deployment-container-image-name "$ACR_NAME.azurecr.io/employee-api:latest"
fi

echo "=============================================="
echo "✅ Deployment complete."
echo "🌐 Your API is available at:"
echo "🔗 https://${APP_NAME}.azurewebsites.net"
echo "=============================================="

# === Test API calls ===
API_URL="https://${APP_NAME}.azurewebsites.net/users"
USER_API_URL="https://${APP_NAME}.azurewebsites.net/users/2"

echo ""
echo "📡 Testing /users endpoint:"
curl -s "$API_URL" | jq

echo ""
echo "📡 Testing /users/2 endpoint:"
curl -s "$USER_API_URL" | jq

echo ""
echo "✅ Sample API calls complete."
echo "📎 Manual usage:"
echo "curl $API_URL"
echo "curl $USER_API_URL"
echo "=============================================="
echo "✅ All tasks completed successfully."
echo "=============================================="