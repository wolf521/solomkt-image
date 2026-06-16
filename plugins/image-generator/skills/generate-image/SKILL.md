---
name: generate-image
description: "Generate AI image from text description using GenerateImage API"
argument-hint: "<image description, e.g. a cat sitting on a mountain at sunrise>"
allowed-tools: [Bash, Read]
---

# Generate Image

You are an image generation assistant. Generate AI images from the user's text descriptions using the GenerateImage API.

## Step 1: Load Configuration

Read the auth config file to check if the API Key is configured:

```bash
auth_file="${CLAUDE_PLUGIN_DATA}/auth.json"
if [[ -f "$auth_file" ]]; then
  node -e '
const fs = require("node:fs");
const data = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
const key = data.api_key || "";
console.log(JSON.stringify({
  config_exists: true,
  base_url: data.base_url || "https://prompt-manager-uat.issmart.com.cn",
  api_key_configured: key.length > 0,
  api_key_preview: key.length > 8 ? key.substring(0, 4) + "****" + key.substring(key.length - 4) : (key ? "****" : "")
}));
' "$auth_file"
else
  echo '{"config_exists": false, "api_key_configured": false}'
fi
```

**If `config_exists` is `false` or `api_key_configured` is `false`:**

1. Tell the user:
   > ⚠️ **API Key not configured.**
   >
   > This plugin requires an API Key to use the GenerateImage API.
   > Please provide your API Key, or contact your system administrator to obtain one.
   >
   > API Endpoint: `https://prompt-manager-uat.issmart.com.cn/app-system-prompt/api/GenerateImage`

2. Ask the user to provide their API Key.

3. Once the user provides the key, save it using the setup command below.

   **Important:** The user may provide the key in various formats:
   - Just the raw key string
   - A JSON object containing the key
   - Key-value format like `API_KEY=xxx` or `api_key=xxx`

   Extract the key value carefully. For example, if the user says:
   - `"sk-abc123..."` → use `sk-abc123...`
   - `{"api_key": "sk-abc123..."}` → use `sk-abc123...`

   Then save it:

   ```bash
   auth_file="${CLAUDE_PLUGIN_DATA}/auth.json"
   base_url="https://prompt-manager-uat.issmart.com.cn"
   api_key="THE_EXTRACTED_API_KEY"

   mkdir -p "$(dirname "$auth_file")"
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
   ' "$auth_file" "$base_url" "$api_key"

   echo "✅ API Key saved to ${auth_file}"
   ```

   After saving, confirm to the user:
   > ✅ API Key configured successfully! Now generating your image...

## Step 2: Generate the Image

Once the API Key is confirmed to exist, call the GenerateImage API.

**Re-read the auth file to get the key (do not use the key from the conversation directly):**

```bash
auth_file="${CLAUDE_PLUGIN_DATA}/auth.json"

# Read API key and base URL from auth.json
read_auth="$(node -e '
const fs = require("node:fs");
const data = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
const values = [data.api_key || "", data.base_url || "https://prompt-manager-uat.issmart.com.cn"];
process.stdout.write(values.join("\t"));
' "$auth_file")"

api_key="${read_auth%%	*}"
base_url="${read_auth#*	}"

# Validate
if [[ -z "$api_key" ]]; then
  echo '{"success": false, "error": "API Key not configured in auth.json"}'
  exit 1
fi

# The user's prompt (use $ARGUMENTS if available, otherwise ask)
prompt="REPLACE_WITH_THE_USER_PROMPT"

# Call the API
endpoint="${base_url%/}/app-system-prompt/api/GenerateImage"
body="$(node -e '
const prompt = process.argv[1];
process.stdout.write(JSON.stringify({ prompt: prompt }));
' "${prompt}")"

curl -sf --max-time 120 \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${api_key}" \
  -d "${body}" \
  "${endpoint}"
```

**Replace `REPLACE_WITH_THE_USER_PROMPT`** with the user's actual image description.

## Step 3: Handle the Response

Parse the JSON response from the API:

### Success (`imageUrl` is present and non-empty)

Display the generated image to the user:

```markdown
Here's your generated image:

![Generated Image](IMAGE_URL_HERE)

**Image URL:** IMAGE_URL_HERE
```

If you can't display the markdown image, provide the direct URL.

### Failure Cases

- **HTTP error / empty response**: Tell the user the API returned an error. Common causes:
  - Invalid API Key (HTTP 401) → suggest re-running setup with a valid key
  - Network timeout → suggest trying again
  - API server error (HTTP 5xx) → suggest trying again later

- **Response contains error fields** (e.g. `{"code": 401, "message": "..."}`):
  Show the error message to the user. If it's an authentication error, suggest updating the API Key.

- **Empty `imageUrl`**: Tell the user the API did not return an image. Show any error details from the response.

## Important Security Notes

- **Never print the API Key** in any output or conversation.
- **Never log the API Key** to any file.
- When showing config status, always mask the key (show only first 4 and last 4 characters).
- Read the API key from `auth.json` for each use — do not reuse the key from earlier conversation turns.
