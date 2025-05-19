#!/bin/bash
set -e

echo "🚀 Starting full environment setup..."

# === Shared context ===
RESOURCE_GROUP=$(gh secret get RESOURCE_GROUP --repo "$REPO_FULL" --jq .value 2>/dev/null || echo "")
ACR_NAME=$(gh secret get ACR_NAME --repo "$REPO_FULL" --jq .value 2>/dev/null || echo "")
SP_APP_ID=$(gh secret list --repo "$REPO_FULL" | grep SP_APP_ID &>/dev/null && gh secret set SP_APP_ID --repo "$REPO_FULL" --output json | jq -r .value 2>/dev/null || echo "")

# === Step 0: Install Environment Tools ===
echo "🔧 [0/5] GitHub CLI authentication..."
chmod +x .github/scripts/tools_config.sh
source .github/scripts/tools_config.sh
echo "✅ Environment tools installed successfully."

# === Step 1: GitHub CLI Login & GH_TOKEN setup ===
echo "🔐 [1/5] GitHub CLI authentication..."
chmod +x .github/scripts/gh_setup.sh
source .github/scripts/gh_setup.sh
echo "✅ GitHub CLI already authenticated."

# === Step 2: Azure CLI Login & Resource Group/SP setup ===
echo "🌐 [2/5] Azure CLI login and resource group setup..."
chmod +x .github/scripts/az_login.sh
source .github/scripts/az_login.sh
echo "✅ Authenticated with Azure CLI."

# === Step 3: Azure Resource Group and Service Principal Setup ===
echo "🏗️ [3/5] Setting up Azure resource group and service principal..."
chmod +x .github/scripts/az_setup.sh
source .github/scripts/az_setup.sh
echo "✅ Azure resource group and service principal setup complete."

# === Step 4: ACR Setup ===
echo "📦 [4/5] ACR configuration..."
chmod +x .github/scripts/acr_setup.sh
source .github/scripts/acr_setup.sh "$RESOURCE_GROUP" "$SP_APP_ID"
echo "✅ Azure Container Registry setup complete."

# === Step 5: Web App Container Configuration ===
echo "🔧 [5/5] Configuring Web App container..."
chmod +x .github/scripts/configure_container.sh
.github/scripts/configure_container.sh "$RESOURCE_GROUP" "$ACR_NAME"
echo "✅ Setup complete and Web App container configured."
