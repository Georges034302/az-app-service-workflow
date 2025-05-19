#!/bin/bash
set -e

if [[ -n "$AZURE_CREDENTIALS" ]]; then
  echo "$AZURE_CREDENTIALS" > creds.json
  echo "🔑 Logging in to Azure CLI using service principal (non-interactive)..."
  az login \
    --service-principal \
    --username "$(jq -r .clientId creds.json)" \
    --password "$(jq -r .clientSecret creds.json)" \
    --tenant "$(jq -r .tenantId creds.json)"
  echo "✅ Logged in to Azure CLI."
  SUBSCRIPTION_ID=$(jq -r .subscriptionId creds.json)
  echo "📘 Subscription ID: $SUBSCRIPTION_ID"
  export SUBSCRIPTION_ID
else
  echo "🔑 No AZURE_CREDENTIALS found. Falling back to interactive login."
  az login
  SUBSCRIPTION_ID=$(az account show --query id -o tsv)
  echo "📘 Subscription ID: $SUBSCRIPTION_ID"
  export SUBSCRIPTION_ID
fi