#!/bin/bash
echo "$AZURE_CREDENTIALS" > creds.json
az login --service-principal --username $(jq -r .clientId creds.json) \
         --password $(jq -r .clientSecret creds.json) \
         --tenant $(jq -r .tenantId creds.json) > /dev/null
az account set --subscription "$AZURE_SUBSCRIPTION_ID"
