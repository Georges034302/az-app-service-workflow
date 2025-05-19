#!/bin/bash
set -e

APP_NAME="azappsvc-sp"

echo "🔍 Searching for Azure AD app registration: $APP_NAME..."
APP_ID=$(az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv)

if [[ -n "$APP_ID" ]]; then
  echo "🧨 Deleting Azure AD app registration with App ID: $APP_ID"
  az ad app delete --id "$APP_ID"
  echo "✅ App registration '$APP_NAME' deleted."
else
  echo "ℹ️  No Azure AD app registration found for: $APP_NAME"
fi

az ad app list --display-name azappsvc-sp --query "[0].appId" -o tsv | xargs az ad app delete --id
az login
