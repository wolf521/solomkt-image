#!/usr/bin/env bash
# common.sh — Shared helpers for image-generator hooks and skills.

set -euo pipefail

IMG_GEN_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMG_GEN_CURL_BIN="${IMG_GEN_CURL_BIN:-curl}"

# ---------- plugin data ----------

img_gen_plugin_data_dir() {
  if [[ -n "${CLAUDE_PLUGIN_DATA:-}" ]]; then
    printf '%s\n' "${CLAUDE_PLUGIN_DATA}"
    return 0
  fi
  return 1
}

# ---------- auth file (${CLAUDE_PLUGIN_DATA}/auth.json) ----------

img_gen_auth_file() {
  local data_dir
  data_dir="$(img_gen_plugin_data_dir)" || return 1
  printf '%s/auth.json\n' "${data_dir}"
}

img_gen_load_auth() {
  # Load base_url and api_key from auth.json.
  # Sets IMG_GEN_BASE_URL, IMG_GEN_API_KEY and exports them.
  # Returns 0 on success, 1 if file missing, 2 if file invalid.

  local auth_file
  auth_file="$(img_gen_auth_file)" || return 1
  if [[ ! -f "${auth_file}" ]]; then
    return 1
  fi

  local parsed base_url api_key
  if ! parsed="$(node -e '
const fs = require("node:fs");
const data = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
const values = [
  data.base_url || "https://prompt-manager-uat.issmart.com.cn",
  data.api_key || ""
];
process.stdout.write(values.join("\t"));
' "${auth_file}")"; then
    return 2
  fi

  IFS=$'\t' read -r base_url api_key <<< "${parsed}"

  if [[ -z "${api_key}" ]]; then
    return 2
  fi

  IMG_GEN_BASE_URL="${base_url}"
  IMG_GEN_API_KEY="${api_key}"

  export IMG_GEN_BASE_URL IMG_GEN_API_KEY
  return 0
}

img_gen_write_auth() {
  # Write auth.json with the given API key.
  # Usage: img_gen_write_auth <api_key> [base_url]
  local api_key="$1"
  local base_url="${2:-https://prompt-manager-uat.issmart.com.cn}"

  local auth_file
  auth_file="$(img_gen_auth_file)" || return 1

  mkdir -p "$(dirname "${auth_file}")"
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
' "${auth_file}" "${base_url}" "${api_key}"
}

# ---------- API ----------

img_gen_api_endpoint() {
  printf '%s/app-system-prompt/api/GenerateImage\n' "${IMG_GEN_BASE_URL%/}"
}

img_gen_call_api() {
  # Call the GenerateImage API.
  # Usage: img_gen_call_api <prompt>
  # Outputs raw JSON response on stdout.
  local prompt="$1"

  local endpoint
  endpoint="$(img_gen_api_endpoint)"

  local body
  body="$(node -e '
const prompt = process.argv[1];
process.stdout.write(JSON.stringify({ prompt: prompt }));
' "${prompt}")"

  "${IMG_GEN_CURL_BIN}" -sf --max-time 120 \
    -H "Content-Type: application/json" \
    -H "X-API-Key: ${IMG_GEN_API_KEY}" \
    -d "${body}" \
    "${endpoint}"
}

# ---------- debug ----------

img_gen_debug_enabled() {
  case "${IMG_GEN_DEBUG:-}" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

img_gen_debug() {
  img_gen_debug_enabled || return 0
  local hook_name="$1"
  local stage="$2"
  shift 2

  local data_dir log_file
  data_dir="$(img_gen_plugin_data_dir)" || return 0
  log_file="${data_dir}/logs/hooks.jsonl"
  mkdir -p "$(dirname "${log_file}")" 2>/dev/null || return 0

  local timestamp
  timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || printf 'unknown')"

  local fields
  fields='"ts":"'"${timestamp}"'","hook":"'"${hook_name}"'","stage":"'"${stage}"'"'

  while [[ "$#" -ge 2 ]]; do
    local key="$1"
    local value="$2"
    shift 2
    # Simple JSON escaping for the value
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    fields="${fields},\"${key}\":\"${value}\""
  done

  printf '{%s}\n' "${fields}" >> "${log_file}" 2>/dev/null || true
}

# ---------- hook helpers ----------

img_gen_hook_get_string() {
  local hook_input="$1"
  local key="$2"
  printf '%s' "${hook_input}" | node "${IMG_GEN_SCRIPT_DIR}/lib/hook-json.mjs" get-string "${key}"
}

img_gen_emit_context() {
  local event_name="$1"
  local text="$2"
  node "${IMG_GEN_SCRIPT_DIR}/lib/hook-json.mjs" emit-context "${event_name}" "${text}"
}
