#!/bin/bash
set -e

echo "🚀 Starting full environment setup..."

# === Step 1: Install Environment Tools ===
echo "🔧 [1/5] GitHub CLI authentication..."
chmod +x .github/scripts/tools_config.sh
source .github/scripts/tools_config.sh
echo "✅ Environment tools installed successfully."

# === Step 2: GitHub CLI Login & GH_TOKEN setup ===
echo "🔐 [2/5] GitHub CLI authentication..."
chmod +x .github/scripts/gh_setup.sh
source .github/scripts/gh_setup.sh
echo "✅ GitHub CLI already authenticated."

# === Step 3: Azure CLI Login & Resource Group/SP setup ===
echo "🌐 [3/5] Azure CLI login and resource group setup..."
chmod +x .github/scripts/az_login.sh
source .github/scripts/az_login.sh
echo "✅ Authenticated with Azure CLI."

# === Step 4: Azure Resource Group and Service Principal Setup ===
echo "🏗️ [4/5] Setting up Azure resource group and service principal..."
chmod +x .github/scripts/az_setup.sh
source .github/scripts/az_setup.sh
echo "✅ Azure resource group and service principal setup complete."

# === Step 5: ACR Setup ===
echo "📦 [5/5] ACR configuration..."
chmod +x .github/scripts/acr_setup.sh
source .github/scripts/acr_setup.sh "$RESOURCE_GROUP" "$SP_APP_ID"
echo "✅ Azure Container Registry setup complete."


