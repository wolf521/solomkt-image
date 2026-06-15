# Generate Image

Use this command when the user asks to generate, create, or produce an image. This command calls the GenerateImage API to produce an AI-generated image based on the given prompt.

## Usage

```
/generate-image <description of the image to generate>
```

## Execution Instructions

When this command is invoked, perform the following steps:

### Step 1: Execute the image generation script

Run the following Python script via the Bash tool. Replace `{USER_PROMPT}` with the actual prompt from `$ARGUMENTS`. If the prompt contains single quotes, escape them as `'\''`.

**Linux/macOS:**
```bash
python3 ~/.claude-image-plugin/generate_image.py generate --prompt '{USER_PROMPT}'
```

**Windows (PowerShell):**
```powershell
python $env:USERPROFILE\.claude-image-plugin\generate_image.py generate --prompt "{USER_PROMPT}"
```

### Step 2: Interpret and present the result

- **Success**: The script outputs JSON: `{"success": true, "imageUrl": "<url>"}`
  - Display the `imageUrl` to the user as a Markdown image: `![generated image](<imageUrl>)`
  - Also show the raw URL for easy copying
- **Failure**: The script outputs JSON: `{"success": false, "error": "<message>"}`
  - Show the error message clearly
  - If the error says "API Key not configured", guide the user through setup:
    1. Ask the user to provide their API Key
    2. Save it by running: `python3 ~/.claude-image-plugin/generate_image.py setup --api-key <KEY>`

## Notes

- `$ARGUMENTS` contains the user's image description prompt — always pass it to the script
- The API Key is stored securely at `~/.claude-image-plugin/config.json`
- The plugin script is located at `~/.claude-image-plugin/generate_image.py` after setup
- If the script is not found, tell the user to run the setup script from the plugin directory
