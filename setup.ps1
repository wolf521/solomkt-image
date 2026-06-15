# Claude Code Image Generation Plugin - Windows Setup Script
# Run this script in PowerShell to install the plugin.

param()

$ErrorActionPreference = "Stop"

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  Claude Code Image Generation Plugin Setup"   -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------------------
# Step 1: Collect API Key
# ---------------------------------------------------------------------------
Write-Host "[Step 1/3] API Key Configuration" -ForegroundColor Yellow
Write-Host "An API Key is required to use the image generation feature."
Write-Host "Please contact your system administrator if you don't have one."
Write-Host ""

$apiKey = Read-Host "Please enter your API Key"

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    Write-Host "ERROR: API Key cannot be empty." -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# Step 2: Create config directory and save API Key
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "[Step 2/3] Saving configuration..." -ForegroundColor Yellow

$configDir  = Join-Path $env:USERPROFILE ".claude-image-plugin"
$configFile = Join-Path $configDir "config.json"

if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

$config = @{ api_key = $apiKey }
$config | ConvertTo-Json | Set-Content -Path $configFile -Encoding UTF8

Write-Host "  Config saved to: $configFile" -ForegroundColor Green

# ---------------------------------------------------------------------------
# Step 3: Install plugin files
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "[Step 3/3] Installing plugin files..." -ForegroundColor Yellow

$pluginDir = $configDir
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceScript = Join-Path $scriptDir "scripts\generate_image.py"

# Copy Python script to plugin dir
Copy-Item -Path $sourceScript -Destination (Join-Path $pluginDir "generate_image.py") -Force
Write-Host "  Installed: generate_image.py" -ForegroundColor Green

# Install slash command to global Claude commands
$globalCommandsDir = Join-Path $env:USERPROFILE ".claude\commands"
if (-not (Test-Path $globalCommandsDir)) {
    New-Item -ItemType Directory -Path $globalCommandsDir -Force | Out-Null
}

$sourceCmd = Join-Path $scriptDir ".claude\commands\generate-image.md"
Copy-Item -Path $sourceCmd -Destination (Join-Path $globalCommandsDir "generate-image.md") -Force
Write-Host "  Installed: generate-image.md (global slash command)" -ForegroundColor Green

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host "  Installation complete!" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""
Write-Host "How to use:" -ForegroundColor White
Write-Host "  In Claude Code, type:  /generate-image a cat wearing a hat"
Write-Host ""
Write-Host "Plugin files:" -ForegroundColor White
Write-Host "  Script : $(Join-Path $pluginDir 'generate_image.py')"
Write-Host "  Config : $configFile"
Write-Host "  Command: $(Join-Path $globalCommandsDir 'generate-image.md')"
Write-Host ""
Write-Host "To reconfigure API Key later, run:" -ForegroundColor White
Write-Host "  python $(Join-Path $pluginDir 'generate_image.py') setup"
Write-Host ""
