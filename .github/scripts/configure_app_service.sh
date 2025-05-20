#!/bin/bash
set -e

APP_NAME="${APP_NAME:-employee-api-appsvc}"
RESOURCE_GROUP="${RESOURCE_GROUP:-}"
ACR_NAME="${ACR_NAME:-}"
REPO_FULL="${REPO_FULL:-}"

# === Validate required inputs ===
if [[ -z "$APP_NAME" || -z "$RESOURCE_GROUP" || -z "$ACR_NAME" || -z "$REPO_FULL" ]]; then
  echo "❌ Missing APP_NAME, RESOURCE_GROUP, ACR_NAME, or REPO_FULL."
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
  az provider register --namespace Microsoft.Web
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

# --- Save APP_NAME to secrets only after success ---
echo "🔐 Saving APP_NAME to GitHub secrets..."
gh secret set APP_NAME --body "$APP_NAME" --repo "$REPO_FULL"

echo "✅ Web App '$APP_NAME' deployed successfully."
echo "=============================================="