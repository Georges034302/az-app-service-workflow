#!/bin/bash
set -e

# === Validate input ===
if [[ -z "$APP_NAME" ]]; then
  echo "❌ APP_NAME is not set. Cannot generate output information."
  exit 1
fi

API_URL="https://${APP_NAME}.azurewebsites.net/users"
USER_API_URL="https://${APP_NAME}.azurewebsites.net/users/2"

echo "=============================================="
echo "✅ Deployment complete."
echo "🌐 Your API is available at:"
echo "🔗 $API_URL"
echo "=============================================="

echo ""
echo "📡 Testing /users endpoint:"
curl -s "$API_URL" | jq || echo "⚠️ Failed to reach /users endpoint"

echo ""
echo "📡 Testing /users/2 endpoint:"
curl -s "$USER_API_URL" | jq || echo "⚠️ Failed to reach /users/2 endpoint"

echo ""
echo "📎 Manual usage:"
echo "curl $API_URL"
echo "curl $USER_API_URL"
echo "=============================================="
echo "✅ All tasks completed successfully."
echo "=============================================="
