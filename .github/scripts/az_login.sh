#!/bin/bash
set -e

echo "🔍 Checking Azure CLI login status..."
if ! az account show &>/dev/null; then
  echo "🔑 Logging in to Azure CLI using device code..."
  az login --use-device-code
else
  echo "✅ Already logged in to Azure CLI."
fi

echo "📘 Getting Azure Subscription ID..."
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "📘 Subscription ID: $SUBSCRIPTION_ID"
export SUBSCRIPTION_ID