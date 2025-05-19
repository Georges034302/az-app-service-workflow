#!/bin/bash
az webapp config container set \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name $ACR_NAME.azurecr.io/employee-api:latest \
  --docker-registry-server-url https://$ACR_NAME.azurecr.io
