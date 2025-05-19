#!/bin/bash
set -e

az group create --name $RESOURCE_GROUP --location australiaeast
az acr create --name $ACR_NAME --resource-group $RESOURCE_GROUP --sku Basic --admin-enabled true
az acr login --name $ACR_NAME
az appservice plan create --name ${APP_NAME}-plan --resource-group $RESOURCE_GROUP --is-linux --sku B1
az webapp create --name $APP_NAME --resource-group $RESOURCE_GROUP --plan ${APP_NAME}-plan --deployment-container-image-name $ACR_NAME.azurecr.io/employee-api:latest
