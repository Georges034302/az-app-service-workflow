#!/bin/bash
set -e

SP_NAME="azappsvc-sp"
SUBSCRIPTION_ID="6c971ef5-5138-44bd-b7df-5d8815a516e1"
TENANT_ID="dd78b53f-4818-46f4-ba7b-5bb24ffe76b0"
REPO_FULL="Georges034302/az-app-service-workflow"  # replace this

echo "🔐 Deleting old SP/app if they exist..."
APP_ID=$(az ad app list --display-name "$SP_NAME" --query "[0].appId" -o tsv)
if [[ -n "$APP_ID" ]]; then
  echo "🧨 Deleting app registration: $APP_ID"
  az ad app delete --id "$APP_ID"
fi

echo "🔑 Creating new SP '$SP_NAME' under subscription $SUBSCRIPTION_ID..."
AZURE_CREDENTIALS=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role contributor \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --sdk-auth)

echo "$AZURE_CREDENTIALS" > sdk.json

echo "✅ Created service principal and stored credentials in sdk.json"

echo "🔎 Verifying service principal login manually..."
az login \
  --service-principal \
  --username "$(jq -r .clientId sdk.json)" \
  --password "$(jq -r .clientSecret sdk.json)" \
  --tenant   "$(jq -r .tenantId sdk.json)"

echo "✅ Manual login successful."

echo "🔐 Uploading to GitHub secrets..."
gh secret set AZURE_CREDENTIALS --body "$AZURE_CREDENTIALS" --repo "$REPO_FULL"

echo "✅ AZURE_CREDENTIALS saved to GitHub. Ready for GitHub Action login."
