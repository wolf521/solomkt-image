# Image Generator - Claude Code Plugin

AI image generation plugin for Claude Code, powered by GenerateImage API.

## Install

```
/plugin marketplace add wolf521/solomkt-image
```

After installation, use the command in Claude Code:

```
/generate-image a cat sitting on a mountain at sunrise
```

**First use will prompt you for an API Key** — contact your system administrator to obtain one.

## Project Structure

```
soloMKT-image/
├── .claude-plugin/
│   └── marketplace.json              # Marketplace manifest (official schema)
├── plugins/
│   └── image-generator/
│       ├── .claude-plugin/
│       │   └── plugin.json           # Plugin metadata (name + author)
│       ├── commands/
│       │   └── generate-image.md     # /generate-image slash command
│       ├── scripts/
│       │   └── generate_image.py     # API call script (Python 3.8+)
│       ├── hooks/
│       │   └── hooks.json            # Lifecycle hooks
│       └── .mcp.json                 # MCP config
├── setup.ps1                         # Windows manual setup
├── setup.sh                          # macOS/Linux manual setup
└── README.md
```

## Usage

```
/generate-image 一杯冒着热气的拿铁咖啡，背景是东京街景
/generate-image futuristic city skyline at night, neon lights
/generate-image 水墨画风格的山水画
```

## API Key

The API Key is stored at `~/.claude-image-plugin/config.json`.

To reconfigure:
```bash
python ~/.claude/plugins/marketplaces/solomkt-image/plugins/image-generator/scripts/generate_image.py setup
```

Or set environment variable: `IMAGE_API_KEY=your-key`

## API Reference

| Field | Value |
|-------|-------|
| Endpoint | `https://prompt-manager-uat.issmart.com.cn/app-system-prompt/api/GenerateImage` |
| Method | `POST` |
| Header | `X-API-Key: <your-key>` |
| Request | `{"prompt": "image description"}` |
| Response | `{"imageUrl": "image url"}` |

## Manual Install (without marketplace)

```bash
# Windows
powershell -ExecutionPolicy Bypass -File .\setup.ps1

# macOS/Linux
chmod +x setup.sh && ./setup.sh
```

## Uninstall

```bash
# Remove plugin
/plugin marketplace remove solomkt-image

# Clean config
rm -rf ~/.claude-image-plugin
```
