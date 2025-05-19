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

echo "🚫 Unsetting GITHUB_TOKEN environment variable..."
unset GITHUB_TOKEN

echo "🔒 Logging out of GitHub CLI for $HOSTNAME (if logged in)..."
gh auth logout --hostname "$HOSTNAME" || true

echo "🔑 Checking GitHub CLI authentication status..."
if ! gh auth status --hostname "$HOSTNAME" &>/dev/null; then
  echo "🔑 Logging in to GitHub CLI with provided GH_TOKEN..."
  echo "$GH_TOKEN" | gh auth login --hostname "$HOSTNAME" --with-token
fi

echo "✅ GitHub CLI authentication status:"
gh auth status

echo "🔐 Saving GH_TOKEN to repository secrets..."
gh secret set GH_TOKEN --body "$GH_TOKEN" --repo "$REPO_FULL"

echo "✅ GH_TOKEN saved to repository secrets."
