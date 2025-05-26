#!/bin/bash
set -e

echo "🔑 Checking Azure CLI login status..."
if az account show &>/dev/null; then
  echo "✅ Already logged in to Azure CLI."
else
  echo "🔑 Starting interactive Azure CLI login..."
  az login
fi

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "📘 Subscription ID: $SUBSCRIPTION_ID"
gh secret set SUBSCRIPTION_ID --body "$SUBSCRIPTION_ID" --repo "$REPO_FULL"
export SUBSCRIPTION_ID