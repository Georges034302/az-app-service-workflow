#!/bin/bash
set -e

echo "🚀 Starting full environment setup..."

# === Shared context ===
RESOURCE_GROUP=$(gh secret get RESOURCE_GROUP --repo "$REPO_FULL" --jq .value 2>/dev/null || echo "")
ACR_NAME=$(gh secret get ACR_NAME --repo "$REPO_FULL" --jq .value 2>/dev/null || echo "")

# === Step 1: Azure Resource Group and Service Principal Setup ===
echo "🏗️ [1/3] Setting up Azure resource group and service principal..."
chmod +x .github/scripts/az_setup.sh
source .github/scripts/az_setup.sh
echo "✅ Azure resource group and service principal setup complete."

# === Step 2: ACR Setup ===
echo "📦 [2/3] ACR configuration..."
chmod +x .github/scripts/acr_setup.sh
source .github/scripts/acr_setup.sh "$RESOURCE_GROUP"
echo "✅ Azure Container Registry setup complete."

# === Step 3: Web App Container Configuration ===
echo "🔧 [3/3] Configuring Web App container..."
chmod +x .github/scripts/container_config.sh
.github/scripts/container_config.sh "$RESOURCE_GROUP" "$ACR_NAME"
echo "✅ Setup complete and Web App container configured."
