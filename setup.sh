#!/usr/bin/env bash
# Claude Code Image Generation Plugin - Linux/macOS Setup Script
set -e

echo "=============================================="
echo "  Claude Code Image Generation Plugin Setup"
echo "=============================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$HOME/.claude-image-plugin"

# ---------------------------------------------------------------------------
# Step 1: Collect API Key
# ---------------------------------------------------------------------------
echo "[Step 1/3] API Key Configuration"
echo "An API Key is required to use the image generation feature."
echo "Please contact your system administrator if you don't have one."
echo ""

read -r -p "Please enter your API Key: " API_KEY

if [ -z "$API_KEY" ]; then
    echo "ERROR: API Key cannot be empty."
    exit 1
fi

# ---------------------------------------------------------------------------
# Step 2: Create config directory and save API Key
# ---------------------------------------------------------------------------
echo ""
echo "[Step 2/3] Saving configuration..."

mkdir -p "$PLUGIN_DIR"
echo "{\"api_key\": \"$API_KEY\"}" > "$PLUGIN_DIR/config.json"
echo "  Config saved to: $PLUGIN_DIR/config.json"

# ---------------------------------------------------------------------------
# Step 3: Install plugin files
# ---------------------------------------------------------------------------
echo ""
echo "[Step 3/3] Installing plugin files..."

# Copy Python script
cp "$SCRIPT_DIR/scripts/generate_image.py" "$PLUGIN_DIR/generate_image.py"
echo "  Installed: generate_image.py"

# Install slash command to global Claude commands
GLOBAL_COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$GLOBAL_COMMANDS_DIR"
cp "$SCRIPT_DIR/.claude/commands/generate-image.md" "$GLOBAL_COMMANDS_DIR/generate-image.md"
echo "  Installed: generate-image.md (global slash command)"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
echo "=============================================="
echo "  Installation complete!"
echo "=============================================="
echo ""
echo "How to use:"
echo "  In Claude Code, type:  /generate-image a cat wearing a hat"
echo ""
echo "Plugin files:"
echo "  Script : $PLUGIN_DIR/generate_image.py"
echo "  Config : $PLUGIN_DIR/config.json"
echo "  Command: $GLOBAL_COMMANDS_DIR/generate-image.md"
echo ""
echo "To reconfigure API Key later, run:"
echo "  python3 $PLUGIN_DIR/generate_image.py setup"
echo ""
