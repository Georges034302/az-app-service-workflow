#!/bin/bash
set -e

APP_NAME="${APP_NAME:-}"
RESOURCE_GROUP="${RESOURCE_GROUP:-}"
ACR_NAME="${ACR_NAME:-}"
REPO_FULL="${REPO_FULL:-}"


# === Validate required inputs ===
if [[ -z "$APP_NAME" || -z "$RESOURCE_GROUP" || -z "$ACR_NAME" || -z "$REPO_FULL" ]]; then
  echo "❌ Missing APP_NAME, RESOURCE_GROUP, ACR_NAME, or REPO_FULL."
  exit 1
fi

# === Login to ACR and build image ===
# STEP 1: Login to Azure Container Registry


# === Ensure Microsoft.Web is registered ===
# STEP 2: Ensure Microsoft.Web resource provider is registered


# === Ensure App Service Plan exists ===
# STEP 3: Ensure App Service Plan exists


# === Ensure Web App exists ===
# STEP 4: Ensure Web App exists
