#!/bin/bash
set -e

echo ""
echo "🚀 Starting full environment setup..."
echo "====================================="

# === Step 1: Install Tools ===
echo "🔧 [1/5] Installing and verifying CLI tools..."
chmod +x .github/scripts/tools_config.sh
source .github/scripts/tools_config.sh
echo "✅ Environment tools verified."
echo ""

# === Step 2: GitHub CLI Login & GH_TOKEN setup ===
echo "🔐 [2/5] Authenticating GitHub CLI and saving GH_TOKEN..."
chmod +x .github/scripts/gh_setup.sh
source .github/scripts/gh_setup.sh
echo "✅ GitHub CLI authentication complete."
echo ""

# === Step 3: Azure CLI Login ===
echo "🌐 [3/5] Authenticating with Azure CLI..."
chmod +x .github/scripts/az_login.sh
source .github/scripts/az_login.sh
echo "✅ Azure CLI login complete."
echo ""

# === Step 4: Resource Group and Service Principal Setup ===
echo "🏗️  [4/5] Creating resource group and service principal..."
chmod +x .github/scripts/az_setup.sh
source .github/scripts/az_setup.sh
echo "✅ Resource group and SP setup complete."
echo ""

# === Step 5: ACR Setup ===
echo "📦 [5/5] Creating ACR and assigning SP role..."
chmod +x .github/scripts/acr_setup.sh
source .github/scripts/acr_setup.sh
echo "✅ ACR setup complete."
echo ""

echo "🎉 Environment setup completed successfully!"
echo "============================================"
