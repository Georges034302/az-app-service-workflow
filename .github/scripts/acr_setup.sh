#!/bin/bash
set -e

ACR_NAME="azacr$RANDOM"
RESOURCE_GROUP="$1"

echo "🔍 Checking if Azure Container Registry '$ACR_NAME' exists in resource group '$RESOURCE_GROUP'..."
if az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
  echo "✅ Azure Container Registry '$ACR_NAME' already exists."
else
  ACR_CREATED=0
  for attempt in {1..5}; do
    echo "🛠️ Attempt $attempt: Creating Azure Container Registry '$ACR_NAME' in resource group '$RESOURCE_GROUP'..."
    az acr create \
      --resource-group "$RESOURCE_GROUP" \
      --name "$ACR_NAME" \
      --sku Basic \
      --location australiaeast \
      --admin-enabled true \
      --only-show-errors \
      --output none && {
        ACR_CREATED=1
        echo "✅ ACR '$ACR_NAME' created."
        break
    }
    echo "⚠️ Attempt $attempt failed. Retrying in 10 seconds..."
    sleep 10
  done

  if [[ $ACR_CREATED -ne 1 ]]; then
    echo "❌ Failed to create Azure Container Registry after 5 attempts."
    exit 1
  fi
fi

echo "🔑 Fetching ACR username..."
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)

echo "🔑 Fetching ACR password..."
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)

echo "🔎 Fetching ACR resource ID..."
ACR_ID=$(az acr show --name "$ACR_NAME" --query id -o tsv)

echo "🔎 Fetching Service Principal App ID from GitHub secrets..."
SP_APP_ID=$(gh secret list --repo "$REPO_FULL" | grep SP_APP_ID | awk '{print $1}' | xargs -I{} gh secret get {} --repo "$REPO_FULL" --jq .value)

echo "🔗 Assigning 'AcrPush' role to Service Principal for ACR..."
az role assignment create \
  --assignee "$SP_APP_ID" \
  --role "AcrPush" \
  --scope "$ACR_ID"

echo "💾 Saving ACR_NAME to GitHub secrets..."
gh secret set ACR_NAME --body "$ACR_NAME" --repo "$REPO_FULL"

echo "💾 Saving ACR_USERNAME to GitHub secrets..."
gh secret set ACR_USERNAME --body "$ACR_USERNAME" --repo "$REPO_FULL"

echo "💾 Saving ACR_PASSWORD to GitHub secrets..."
gh secret set ACR_PASSWORD --body "$ACR_PASSWORD" --repo "$REPO_FULL"

echo "✅ ACR setup and all related secrets saved."
