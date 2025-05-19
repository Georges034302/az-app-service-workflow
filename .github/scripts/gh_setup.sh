#!/bin/bash
set -e

HOSTNAME="github.com"

echo "🔗 Extracting OWNER and REPO from git remote URL..."
REMOTE_URL=$(git config --get remote.origin.url)
if [[ "$REMOTE_URL" =~ github.com[:/]+([^/]+)/([^.]+)(\.git)?$ ]]; then
  OWNER="${BASH_REMATCH[1]}"
  REPO="${BASH_REMATCH[2]}"
  REPO_FULL="$OWNER/$REPO"
  echo "   OWNER: $OWNER"
  echo "   REPO: $REPO"
  echo "   REPO_FULL: $REPO_FULL"
else
  echo "❌ Could not parse OWNER and REPO from remote URL: $REMOTE_URL"
  exit 1
fi
export REPO_FULL

echo "🔑 Authenticating GitHub CLI using GH_TOKEN from environment (non-interactive)..."
if [[ -z "$GH_TOKEN" ]]; then
  echo "❌ GH_TOKEN is not set in the environment. Please ensure it is available (e.g., in ~/.bashrc or as an environment variable)."
  exit 1
fi

# Unset GITHUB_TOKEN to allow gh CLI to store credentials
unset GITHUB_TOKEN

echo "$GH_TOKEN" | gh auth login --with-token --hostname "$HOSTNAME" --git-protocol https

echo "✅ GitHub CLI authenticated using GH_TOKEN (no web login required)."

echo "🔐 Saving GH_TOKEN to repository secrets..."
gh secret set GH_TOKEN --body "$GH_TOKEN" --repo "$REPO_FULL"

echo "✅ GH_TOKEN saved to repository secrets."
