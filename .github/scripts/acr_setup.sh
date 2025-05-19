#!/bin/bash
set -e

# --- Required inputs from env or secrets ---
ACR_NAME="${ACR_NAME:-}"
RESOURCE_GROUP="${RESOURCE_GROUP:-}"
SP_APP_ID="${SP_APP_ID:-}"
REPO_FULL="${REPO_FULL:-}"

# --- Validate inputs ---
if [[ -z "$ACR_NAME" || -z "$RESOURCE_GROUP" || -z "$SP_APP_ID" || -z "$REPO_FULL" ]]; then
  echo "❌ Missing required environment variables: ACR_NAME, RESOURCE_GROUP, SP_APP_ID, or REPO_FULL"
  exit 1
fi

# --- Check if ACR already exists ---
echo "🔍 Checking if Azure Container Registry '$ACR_NAME' exists in resource group '$RESOURCE_GROUP'..."
if az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
  echo "✅ ACR '$ACR_NAME' already exists. Skipping creation."
else
  echo "📦 Creating ACR '$ACR_NAME' in resource group '$RESOURCE_GROUP'..."
  for attempt in {1..5}; do
    if az acr create \
      --resource-group "$RESOURCE_GROUP" \
      --name "$ACR_NAME" \
      --sku Basic \
      --location australiaeast \
      --admin-enabled true \
      --only-show-errors \
      --output none; then
      echo "✅ ACR '$ACR_NAME' created."
      break
    else
      echo "⚠️ Attempt $attempt failed. Retrying in 10 seconds..."
      sleep 10
    fi

    if [[ $attempt -eq 5 ]]; then
      echo "❌ Failed to create ACR after 5 attempts."
      exit 1
    fi
  done
fi

# --- Fetch ACR credentials ---
echo "🔑 Fetching ACR credentials..."
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)
ACR_ID=$(az acr show --name "$ACR_NAME" --query id -o tsv)

# --- Assign AcrPush role to SP ---
echo "🔗 Assigning 'AcrPush' role to SP '$SP_APP_ID' on ACR '$ACR_NAME'..."
az role assignment create \
  --assignee "$SP_APP_ID" \
  --role "AcrPush" \
  --scope "$ACR_ID"

# --- Save secrets ---
echo "💾 Saving ACR credentials to GitHub secrets..."
gh secret set ACR_NAME --body "$ACR_NAME" --repo "$REPO_FULL"
gh secret set ACR_USERNAME --body "$ACR_USERNAME" --repo "$REPO_FULL"
gh secret set ACR_PASSWORD --body "$ACR_PASSWORD" --repo "$REPO_FULL"

echo "✅ ACR setup and secrets saved."
