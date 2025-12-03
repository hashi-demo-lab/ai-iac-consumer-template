#!/bin/bash
# Post-create setup script for Claude Code devcontainer
set -e

echo "=== Post-Create Setup Starting ==="

# 1. Configure Terraform credentials
echo "[1/3] Configuring Terraform credentials..."
mkdir -p ~/.terraform.d
cat > ~/.terraform.d/credentials.tfrc.json << EOF
{
  "credentials": {
    "app.terraform.io": {
      "token": "${TFE_TOKEN}"
    }
  }
}
EOF
echo "      Terraform credentials configured"

# 2. Install and build Claude hooks for Langfuse tracing
echo "[2/3] Setting up Claude hooks..."
if [ -f /workspace/.claude/hooks/package.json ]; then
  cd /workspace/.claude/hooks
  npm install --silent
  npm run build
  echo "      Claude hooks installed and built"

  # Run health check
  if [ -f scripts/health-check.sh ]; then
    echo "      Running hooks health check..."
    bash scripts/health-check.sh || echo "      (Some health checks may require Langfuse credentials)"
  fi
else
  echo "      No hooks found at /workspace/.claude/hooks - skipping"
fi

# 3. Sync project Claude settings to user config
echo "[3/3] Syncing Claude settings..."
if [ -f /workspace/.claude/settings.json ]; then
  # Merge project hooks settings with user settings
  # The volume-mounted /home/node/.claude may already have settings
  if [ -f /home/node/.claude/settings.json ]; then
    echo "      User settings exist - hooks will be loaded from project .claude/settings.json"
  else
    echo "      Creating user settings directory link"
  fi
fi

echo ""
echo "=== Post-Create Setup Complete ==="
echo ""
echo "Claude hooks status:"
echo "  - Langfuse tracing: $([ -f /workspace/.claude/hooks/dist/langfuse-hook.js ] && echo 'Ready' || echo 'Not built')"
echo "  - LANGFUSE_PUBLIC_KEY: $([ -n \"$LANGFUSE_PUBLIC_KEY\" ] && echo 'configured' || echo 'missing')"
echo "  - LANGFUSE_SECRET_KEY: $([ -n \"$LANGFUSE_SECRET_KEY\" ] && echo 'configured' || echo 'missing')"
echo ""
