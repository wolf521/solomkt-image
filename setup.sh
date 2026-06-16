#!/usr/bin/env bash
# ============================================================================
# Image Generator Plugin — macOS / Linux Setup
# ============================================================================
# This script helps you configure the API Key and install the plugin manually.
#
# Usage:
#   ./setup.sh                     # Interactive mode
#   ./setup.sh --api-key <KEY>     # Non-interactive mode
#   ./setup.sh --help              # Show help
# ============================================================================

set -euo pipefail

# ---- helpers ----

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_step() { echo -e "${CYAN}[Step $1]${NC} $2"; }
print_ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
print_err()  { echo -e "  ${RED}✗${NC} $1"; }
print_warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- parse args ----

API_KEY=""
BASE_URL="https://prompt-manager-uat.issmart.com.cn"
PLUGIN_DATA_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --api-key)
      API_KEY="$2"
      shift 2
      ;;
    --base-url)
      BASE_URL="$2"
      shift 2
      ;;
    --plugin-data-dir)
      PLUGIN_DATA_DIR="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: ./setup.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --api-key <KEY>          API Key (non-interactive mode)"
      echo "  --base-url <URL>         API base URL (default: https://prompt-manager-uat.issmart.com.cn)"
      echo "  --plugin-data-dir <DIR>  Override Claude Code plugin data directory"
      echo "  --help, -h               Show this help"
      echo ""
      echo "Examples:"
      echo "  ./setup.sh"
      echo "  ./setup.sh --api-key sk-abc123"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# ---- banner ----

echo ""
echo -e "${CYAN}==============================================${NC}"
echo -e "${CYAN}  Image Generator Plugin Setup${NC}"
echo -e "${CYAN}  v1.0.0${NC}"
echo -e "${CYAN}==============================================${NC}"
echo ""

# ---- Step 1: Check Node.js ----

print_step "1/3" "Checking Node.js..."

if ! command -v node &>/dev/null; then
  print_err "Node.js is not installed."
  echo ""
  echo "  This plugin requires Node.js 18+ for JSON operations."
  echo "  Install it from: https://nodejs.org"
  echo ""
  exit 1
fi

NODE_VERSION="$(node -e 'console.log(process.versions.node)')"
NODE_MAJOR="$(node -e 'console.log(process.versions.node.split(".")[0])')"
if [[ "$NODE_MAJOR" -lt 18 ]]; then
  print_err "Node.js 18+ required (found: v${NODE_VERSION})"
  echo "  Please upgrade from: https://nodejs.org"
  exit 1
fi
print_ok "Node.js v${NODE_VERSION}"

# ---- Step 2: Collect API Key ----

echo ""
print_step "2/3" "API Key Configuration"
echo ""
echo "  API Endpoint: ${BASE_URL}/app-system-prompt/api/GenerateImage"
echo "  Please contact your system administrator to obtain your API Key."
echo ""

if [[ -z "${API_KEY}" ]]; then
  read -r -p "  Enter your API Key: " API_KEY
fi

if [[ -z "${API_KEY}" ]]; then
  echo ""
  print_err "API Key cannot be empty. Setup aborted."
  echo "  Re-run: ./setup.sh"
  exit 1
fi

# ---- Step 3: Determine plugin data directory & write auth.json ----

echo ""
print_step "3/3" "Writing configuration..."

# Use specified dir, or CLAUDE_PLUGIN_DATA from env, or fall back to defaults
if [[ -z "${PLUGIN_DATA_DIR}" ]]; then
  if [[ -n "${CLAUDE_PLUGIN_DATA:-}" ]]; then
    PLUGIN_DATA_DIR="${CLAUDE_PLUGIN_DATA}"
  else
    # Best-effort fallback for manual installs
    case "$(uname -s)" in
      Darwin)  PLUGIN_DATA_DIR="${HOME}/Library/Application Support/ClaudeCode/plugin-data" ;;
      Linux)   PLUGIN_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/ClaudeCode/plugin-data" ;;
      *)       PLUGIN_DATA_DIR="${HOME}/.claude/plugin-data" ;;
    esac
    print_warn "CLAUDE_PLUGIN_DATA not set. Using fallback path: ${PLUGIN_DATA_DIR}"
  fi
fi

AUTH_FILE="${PLUGIN_DATA_DIR}/auth.json"
mkdir -p "$(dirname "${AUTH_FILE}")"

node -e '
const fs = require("node:fs");
const path = require("node:path");
const authPath = process.argv[1];
const baseUrl = process.argv[2];
const apiKey = process.argv[3];
const payload = {
  base_url: baseUrl,
  api_key: apiKey,
  created_at: new Date().toISOString(),
  source: "manual_config"
};
fs.mkdirSync(path.dirname(authPath), { recursive: true });
fs.writeFileSync(authPath, JSON.stringify(payload, null, 2) + "\n");
console.log("Config written to: " + authPath);
' "${AUTH_FILE}" "${BASE_URL}" "${API_KEY}"

print_ok "Configuration saved to: ${AUTH_FILE}"

# ---- Done ----

echo ""
echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}  Setup complete!${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo "  Next steps:"
echo ""
echo "  1. Install the plugin in Claude Code:"
echo ""
echo "     # From marketplace:"
echo "     claude plugin marketplace add wolf521/solomkt-image"
echo "     claude plugin install image-generator@solomkt-image"
echo ""
echo "     # Or from local path:"
echo "     claude plugin install ${SCRIPT_DIR}/plugins/image-generator"
echo ""
echo "  2. Restart Claude Code (or start a new session)"
echo ""
echo "  3. Try it out:"
echo "     /generate-image a cat sitting on a mountain at sunrise"
echo ""
echo "  Configuration:"
echo "    Auth file : ${AUTH_FILE}"
echo "    Base URL  : ${BASE_URL}"
echo ""
echo "  To reconfigure:"
echo "    Delete ${AUTH_FILE} and re-run this script,"
echo "    or simply run /generate-image in Claude Code for interactive setup."
echo ""
