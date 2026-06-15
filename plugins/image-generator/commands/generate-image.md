---
description: "Generate AI image from text description using GenerateImage API"
argument-hint: "<image description, e.g. a cat sitting on a mountain at sunrise>"
allowed-tools: ["Bash", "Read"]
---

# Generate Image

Generate an AI image from the user's text description using the GenerateImage API.

## Step 1: Check API Key Configuration

First, run the config check to see if the API Key is already set up:

```!
python "${CLAUDE_PLUGIN_ROOT}/scripts/generate_image.py" config --show
```

If the output shows `"config_exists": false` or the API Key is missing/empty:

1. **Ask the user to provide their API Key** - tell them:
   > "This plugin requires an API Key to use the GenerateImage API.
   > Please contact your system administrator to obtain your API Key.
   > API Endpoint: https://prompt-manager-uat.issmart.com.cn/app-system-prompt/api/GenerateImage"
2. Once the user provides the key, save it:

```!
python "${CLAUDE_PLUGIN_ROOT}/scripts/generate_image.py" setup --api-key "THE_USER_PROVIDED_KEY"
```

## Step 2: Generate the Image

Run the generation script with the user's prompt from `$ARGUMENTS`:

```!
python "${CLAUDE_PLUGIN_ROOT}/scripts/generate_image.py" generate --prompt "$ARGUMENTS"
```

## Step 3: Present the Result

Parse the JSON output from the script:

- **Success** (`"success": true`): Display the image to the user:
  ```markdown
  ![generated image](IMAGE_URL_HERE)

  Image URL: IMAGE_URL_HERE
  ```

- **Failure** (`"success": false`): Show the error message clearly and suggest fixes:
  - If `API Key not configured`: Go back to Step 1
  - If `API error 401`: Tell the user their API Key is invalid, suggest re-running setup
  - If `Network error`: Tell the user to check their network connection
