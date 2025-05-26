#!/bin/bash
set -e

# --- Load environment or fallback defaults ---
RESOURCE_GROUP="${RESOURCE_GROUP:-}"
SP_APP_ID="${SP_APP_ID:-}"
REPO_FULL="${REPO_FULL:-}"
OWNER="${OWNER:-}"

# --- Validate inputs ---
if [[ -z "$RESOURCE_GROUP" || -z "$SP_APP_ID" || -z "$REPO_FULL" ]]; then
  echo "❌ Missing required environment variables: RESOURCE_GROUP, SP_APP_ID, or REPO_FULL."
  exit 1
fi

# --- Set ACR_NAME if not already set ---
if ! gh secret list --repo "$REPO_FULL" | grep -q "ACR_NAME"; then
  if [[ -z "$OWNER" ]]; then
    echo "❌ OWNER is required to compute ACR_NAME. Please export OWNER='your-org' and rerun."
    exit 1
  fi

  CLEAN_OWNER="${OWNER//[^a-zA-Z0-9]/}"     # Remove special chars
  ACR_NAME="az${CLEAN_OWNER,,}acr"          # Lowercase
  ACR_NAME="${ACR_NAME:0:50}"               # Azure limit
  echo "🔧 Generated ACR_NAME: $ACR_NAME"

  gh secret set ACR_NAME --body "$ACR_NAME" --repo "$REPO_FULL"
  echo "✅ ACR_NAME saved to GitHub Secrets."
else
  echo "✅ ACR_NAME already exists in GitHub Secrets. Assuming it's set at runtime."
  ACR_NAME=$(az acr list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv)
fi

# --- Create ACR if not exists ---
echo "🔍 Checking if ACR '$ACR_NAME' exists in RG '$RESOURCE_GROUP'..."
if az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
  echo "✅ ACR '$ACR_NAME' already exists."
else
  echo "📦 Creating ACR '$ACR_NAME'..."
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

# --- Fetch credentials ---
echo "🔑 Fetching ACR credentials..."
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)
ACR_ID=$(az acr show --name "$ACR_NAME" --query id -o tsv)

# --- Assign 'AcrPush' role to SP ---
if az role assignment list --assignee "$SP_APP_ID" --scope "$ACR_ID" --query "[?roleDefinitionName=='AcrPush']" -o tsv | grep -q "AcrPush"; then
  echo "✅ 'AcrPush' role already assigned to SP."
else
  echo "🔗 Assigning 'AcrPush' role to SP..."
  az role assignment create \
    --assignee "$SP_APP_ID" \
    --role "AcrPush" \
    --scope "$ACR_ID"
  echo "✅ 'AcrPush' role assigned."
fi

# --- Save ACR credentials to GitHub Secrets ---
echo "💾 Saving ACR credentials to GitHub Secrets..."
gh secret set ACR_USERNAME --body "$ACR_USERNAME" --repo "$REPO_FULL"
gh secret set ACR_PASSWORD --body "$ACR_PASSWORD" --repo "$REPO_FULL"

echo "✅ ACR setup complete and secrets saved."

echo "============================================================"
echo "🔧 Configuring APP_NAME..."
APP_NAME="${APP_NAME:-employee-api-appsvc}"

echo "🔐 Saving APP_NAME='$APP_NAME' to GitHub secrets..."
if gh secret set APP_NAME --body "$APP_NAME" --repo "$REPO_FULL"; then
  echo "✅ APP_NAME secret saved."
else
  echo "❌ Failed to save APP_NAME. Are you running inside GitHub Actions?"
fi
echo "============================================================"



