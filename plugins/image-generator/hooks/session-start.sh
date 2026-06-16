#!/usr/bin/env bash
# session-start.sh — Check auth.json status on startup and emit reminder if missing.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/common.sh"

HOOK_INPUT="$(cat)"

SESSION_SOURCE="$(img_gen_hook_get_string "${HOOK_INPUT}" "source")"
img_gen_debug "SessionStart" "hook_started" "source" "${SESSION_SOURCE:-unknown}"

# Only run on startup (not on resume / compact / etc.)
if [[ "${SESSION_SOURCE}" != "startup" ]]; then
  img_gen_debug "SessionStart" "skipped_non_startup" "source" "${SESSION_SOURCE:-unknown}"
  exit 0
fi

# Check auth
load_status=0
if img_gen_load_auth 2>/dev/null; then
  img_gen_debug "SessionStart" "auth_ready" "source" "${SESSION_SOURCE}"
  img_gen_emit_context "SessionStart" "[image-generator] API Key configured. Use /generate-image to create images."
  exit 0
else
  load_status=$?
fi

if [[ "${load_status}" -eq 2 ]]; then
  img_gen_debug "SessionStart" "auth_invalid" "source" "${SESSION_SOURCE}"
  img_gen_emit_context "SessionStart" "[image-generator] auth.json is invalid or the API Key is empty. Use /generate-image and provide your API Key when prompted."
  exit 0
fi

# auth.json not found
img_gen_debug "SessionStart" "auth_missing" "source" "${SESSION_SOURCE}"
img_gen_emit_context "SessionStart" "[image-generator] No API Key configured yet. To use image generation, run /generate-image — the plugin will guide you through setup. API Key can be obtained from the GenerateImage API administrator (https://prompt-manager-uat.issmart.com.cn)."
