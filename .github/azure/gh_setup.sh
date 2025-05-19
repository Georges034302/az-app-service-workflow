#!/bin/bash
set -e

HOSTNAME="github.com"

echo "👤 Getting GitHub username..."
export OWNER=$(gh api user --jq .login)

echo "📦 Getting repository name..."
export REPO=$(basename -s .git "$(git config --get remote.origin.url)")

echo "🔗 Setting full repository name..."
export REPO_FULL="$OWNER/$REPO"

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
