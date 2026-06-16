# ============================================================================
# Image Generator Plugin — Windows Setup
# ============================================================================
# This script helps you configure the API Key and install the plugin manually.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1 -ApiKey "your-key"
# ============================================================================

param(
    [string]$ApiKey = "",
    [string]$BaseUrl = "https://prompt-manager-uat.issmart.com.cn",
    [string]$PluginDataDir = "",
    [switch]$Help = $false
)

if ($Help) {
    Write-Host "Usage: powershell -ExecutionPolicy Bypass -File .\setup.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -ApiKey <KEY>            API Key (non-interactive mode)"
    Write-Host "  -BaseUrl <URL>           API base URL (default: https://prompt-manager-uat.issmart.com.cn)"
    Write-Host "  -PluginDataDir <DIR>     Override Claude Code plugin data directory"
    Write-Host "  -Help                    Show this help"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\setup.ps1"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\setup.ps1 -ApiKey sk-abc123"
    exit 0
}

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ---- banner ----

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  Image Generator Plugin Setup" -ForegroundColor Cyan
Write-Host "  v1.0.0" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# ---- Step 1: Check Node.js ----

Write-Host "[Step 1/3] Checking Node.js..." -ForegroundColor Cyan

$nodeVersion = $null
try {
    $nodeVersion = & node -e "console.log(process.versions.node)" 2>&1
    if ($LASTEXITCODE -ne 0) { throw "node not found" }
} catch {
    Write-Host "  X Node.js is not installed." -ForegroundColor Red
    Write-Host ""
    Write-Host "  This plugin requires Node.js 18+ for JSON operations."
    Write-Host "  Install it from: https://nodejs.org"
    Write-Host ""
    exit 1
}

$nodeMajor = & node -e "console.log(process.versions.node.split('.')[0])"
if ([int]$nodeMajor -lt 18) {
    Write-Host "  X Node.js 18+ required (found: v$nodeVersion)" -ForegroundColor Red
    Write-Host "  Please upgrade from: https://nodejs.org"
    exit 1
}
Write-Host "  OK Node.js v$nodeVersion" -ForegroundColor Green

# ---- Step 2: Collect API Key ----

Write-Host ""
Write-Host "[Step 2/3] API Key Configuration" -ForegroundColor Cyan
Write-Host ""
Write-Host "  API Endpoint: $BaseUrl/app-system-prompt/api/GenerateImage"
Write-Host "  Please contact your system administrator to obtain your API Key."
Write-Host ""

if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $ApiKey = Read-Host "  Enter your API Key"
}

if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    Write-Host ""
    Write-Host "  X API Key cannot be empty. Setup aborted." -ForegroundColor Red
    Write-Host "  Re-run: powershell -ExecutionPolicy Bypass -File .\setup.ps1"
    exit 1
}

# ---- Step 3: Determine plugin data directory & write auth.json ----

Write-Host ""
Write-Host "[Step 3/3] Writing configuration..." -ForegroundColor Cyan

if ([string]::IsNullOrWhiteSpace($PluginDataDir)) {
    $envData = $env:CLAUDE_PLUGIN_DATA
    if ($envData) {
        $PluginDataDir = $envData
    } else {
        # Best-effort fallback for manual installs
        $PluginDataDir = Join-Path $env:APPDATA "ClaudeCode\plugin-data"
        Write-Host "  ! CLAUDE_PLUGIN_DATA not set. Using fallback path: $PluginDataDir" -ForegroundColor Yellow
    }
}

$authFile = Join-Path $PluginDataDir "auth.json"
$authDir = Split-Path $authFile -Parent

if (-not (Test-Path $authDir)) {
    New-Item -ItemType Directory -Path $authDir -Force | Out-Null
}

$payload = @{
    base_url   = $BaseUrl
    api_key    = $ApiKey
    created_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ")
    source     = "manual_config"
}

$payload | ConvertTo-Json -Depth 10 | Set-Content -Path $authFile -Encoding UTF8

Write-Host "  OK Configuration saved to: $authFile" -ForegroundColor Green

# ---- Done ----

Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Next steps:"
Write-Host ""
Write-Host "  1. Install the plugin in Claude Code:"
Write-Host ""
Write-Host "     # From marketplace:"
Write-Host "     claude plugin marketplace add wolf521/solomkt-image"
Write-Host "     claude plugin install image-generator@solomkt-image"
Write-Host ""
Write-Host "     # Or from local path:"
Write-Host "     claude plugin install $scriptDir\plugins\image-generator"
Write-Host ""
Write-Host "  2. Restart Claude Code (or start a new session)"
Write-Host ""
Write-Host "  3. Try it out:"
Write-Host "     /generate-image a cat sitting on a mountain at sunrise"
Write-Host ""
Write-Host "  Configuration:"
Write-Host "    Auth file : $authFile"
Write-Host "    Base URL  : $BaseUrl"
Write-Host ""
Write-Host "  To reconfigure:"
Write-Host "    Delete $authFile and re-run this script,"
Write-Host "    or simply run /generate-image in Claude Code for interactive setup."
Write-Host ""
