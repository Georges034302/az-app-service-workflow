#!/bin/bash
set -e

echo "🔑 Logging in to Azure Container Registry '$ACR_NAME'..."
az acr login --name "$ACR_NAME"

echo "🛠️ Building Docker image for employee-api..."
docker build -t "$ACR_NAME.azurecr.io/employee-api:latest" .

echo "📤 Pushing Docker image to ACR..."
docker push "$ACR_NAME.azurecr.io/employee-api:latest"

echo "🖥️ Creating App Service plan '${APP_NAME}-plan' in resource group '$RESOURCE_GROUP'..."
az appservice plan create \
  --name "${APP_NAME}-plan" \
  --resource-group "$RESOURCE_GROUP" \
  --is-linux \
  --sku B1

echo "🚀 Creating Web App '$APP_NAME' and deploying container image..."
az webapp create \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --plan "${APP_NAME}-plan" \
  --deployment-container-image-name "$ACR_NAME.azurecr.io/employee-api:latest"

echo "=============================================="
echo "✅ Deployment complete."
echo "🌐 Your API is available at:"
echo "https://${APP_NAME}.azurewebsites.net"
echo "=============================================="

echo ""
echo "📡 Making test API call to /users endpoint..."
API_URL="https://${APP_NAME}.azurewebsites.net/users"
curl -s "$API_URL" | jq

echo ""
echo "📡 Making test API call to /users/2 endpoint..."
USER_API_URL="https://${APP_NAME}.azurewebsites.net/users/2"
curl -s "$USER_API_URL" | jq

echo ""
echo "✅ Sample API calls complete. You can use:"
echo "curl $API_URL"
echo "curl $USER_API_URL"
