#!/bin/bash
set -e

echo "🧰 Validating required CLI tools..."

# Helper: Use sudo only if available
use_sudo_if_available() {
  if command -v sudo &>/dev/null; then
    sudo "$@"
  else
    "$@"
  fi
}

# --- Azure CLI ---
echo "🔍 Checking for Azure CLI (az)..."
if ! command -v az &>/dev/null; then
  echo "⚠️ Azure CLI not found. Installing..."
  curl -sL https://aka.ms/InstallAzureCLIDeb | bash
else
  echo "✅ Azure CLI is already installed."
fi

# --- jq ---
echo "🔍 Checking for jq..."
if ! command -v jq &>/dev/null; then
  echo "⚠️ jq not found. Installing..."
  apt-get update && apt-get install -y jq
else
  echo "✅ jq is already installed."
fi

# --- GitHub CLI ---
echo "🔍 Checking for GitHub CLI (gh)..."
if ! command -v gh &>/dev/null; then
  echo "⚠️ GitHub CLI not found. Installing..."
  apt-get update && apt-get install -y curl
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list
  apt-get update && apt-get install -y gh
else
  echo "✅ GitHub CLI is already installed."
fi

echo "✅ All required tools are installed and ready."
