#!/usr/bin/env bash
# Claude Code Image Generation Plugin - Linux/macOS Setup Script
# Marketplace-compatible installer
set -e

echo "=============================================="
echo "  Image Generator Plugin Setup"
echo "  Marketplace Installer v1.0"
echo "=============================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$SCRIPT_DIR/plugins/image-generator"
INSTALL_DIR="$HOME/.claude-image-plugin"
COMMANDS_DIR="$HOME/.claude/commands"

# ---------------------------------------------------------------------------
# Step 1: Collect API Key
# ---------------------------------------------------------------------------
echo "[Step 1/3] API Key Configuration"
echo ""
echo "  This plugin requires an API Key to access the GenerateImage service."
echo "  API Endpoint: https://prompt-manager-uat.issmart.com.cn/app-system-prompt/api/GenerateImage"
echo "  Please contact your system administrator to obtain your API Key."
echo ""

if [ -n "$1" ]; then
    API_KEY="$1"
else
    read -r -p "  Please enter your API Key: " API_KEY
fi

if [ -z "$API_KEY" ]; then
    echo ""
    echo "  ERROR: API Key cannot be empty. Installation aborted."
    echo "  Re-run: ./setup.sh"
    exit 1
fi

# ---------------------------------------------------------------------------
# Step 2: Save configuration
# ---------------------------------------------------------------------------
echo ""
echo "[Step 2/3] Saving configuration..."

mkdir -p "$INSTALL_DIR"
echo "{\"api_key\": \"$API_KEY\"}" > "$INSTALL_DIR/config.json"
echo "  Config saved to: $INSTALL_DIR/config.json"

# ---------------------------------------------------------------------------
# Step 3: Install plugin files
# ---------------------------------------------------------------------------
echo ""
echo "[Step 3/3] Installing plugin files..."

# 3a. Copy Python script
cp "$PLUGIN_DIR/scripts/generate_image.py" "$INSTALL_DIR/generate_image.py"
echo "  Installed: generate_image.py -> $INSTALL_DIR"

# 3b. Install slash command (global)
mkdir -p "$COMMANDS_DIR"
cp "$PLUGIN_DIR/commands/generate-image.md" "$COMMANDS_DIR/generate-image.md"
echo "  Installed: generate-image.md -> $COMMANDS_DIR"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
echo "=============================================="
echo "  Installation complete!"
echo "=============================================="
echo ""
echo "  How to use:"
echo "    In Claude Code, type:  /generate-image a cat wearing a hat"
echo ""
echo "  Installed files:"
echo "    Script : $INSTALL_DIR/generate_image.py"
echo "    Config : $INSTALL_DIR/config.json"
echo "    Command: $COMMANDS_DIR/generate-image.md"
echo ""
echo "  Management:"
echo "    Reconfigure API Key: python3 $INSTALL_DIR/generate_image.py setup"
echo "    View config:         python3 $INSTALL_DIR/generate_image.py config --show"
echo "    Uninstall:           rm -rf $INSTALL_DIR && rm -f $COMMANDS_DIR/generate-image.md"
echo ""
