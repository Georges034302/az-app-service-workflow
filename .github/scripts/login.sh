#!/bin/bash
set -e

echo "🔑🔵 Logging in to GitHub and Azure ..."

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