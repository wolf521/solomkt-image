# Claude Code Image Generation Plugin - Windows Setup Script
# Marketplace-compatible installer
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1 -ApiKey "your-key"

param(
    [string]$ApiKey = ""
)

$ErrorActionPreference = "Stop"

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  Image Generator Plugin Setup" -ForegroundColor Cyan
Write-Host "  Marketplace Installer v1.0" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$pluginDir   = Join-Path $scriptDir "plugins\image-generator"
$installDir  = Join-Path $env:USERPROFILE ".claude-image-plugin"
$commandsDir = Join-Path $env:USERPROFILE ".claude\commands"

# ---------------------------------------------------------------------------
# Step 1: Collect API Key
# ---------------------------------------------------------------------------
Write-Host "[Step 1/3] API Key Configuration" -ForegroundColor Yellow
Write-Host ""
Write-Host "  This plugin requires an API Key to access the GenerateImage service."
Write-Host "  API Endpoint: https://prompt-manager-uat.issmart.com.cn/app-system-prompt/api/GenerateImage"
Write-Host "  Please contact your system administrator to obtain your API Key."
Write-Host ""

if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $ApiKey = Read-Host "  Please enter your API Key"
}

if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    Write-Host ""
    Write-Host "  ERROR: API Key cannot be empty. Installation aborted." -ForegroundColor Red
    Write-Host "  Re-run: powershell -ExecutionPolicy Bypass -File .\setup.ps1" -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# Step 2: Save configuration
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "[Step 2/3] Saving configuration..." -ForegroundColor Yellow

if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

$configFile = Join-Path $installDir "config.json"
$config = @{ api_key = $ApiKey }
$config | ConvertTo-Json | Set-Content -Path $configFile -Encoding UTF8

Write-Host "  Config saved to: $configFile" -ForegroundColor Green

# ---------------------------------------------------------------------------
# Step 3: Install plugin files
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "[Step 3/3] Installing plugin files..." -ForegroundColor Yellow

# 3a. Copy Python script
$srcScript = Join-Path $pluginDir "scripts\generate_image.py"
$dstScript = Join-Path $installDir "generate_image.py"
Copy-Item -Path $srcScript -Destination $dstScript -Force
Write-Host "  Installed: generate_image.py -> $installDir" -ForegroundColor Green

# 3b. Install slash command (global)
if (-not (Test-Path $commandsDir)) {
    New-Item -ItemType Directory -Path $commandsDir -Force | Out-Null
}

$srcCmd = Join-Path $pluginDir "commands\generate-image.md"
$dstCmd = Join-Path $commandsDir "generate-image.md"
Copy-Item -Path $srcCmd -Destination $dstCmd -Force
Write-Host "  Installed: generate-image.md -> $commandsDir" -ForegroundColor Green

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host "  Installation complete!" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  How to use:" -ForegroundColor White
Write-Host "    In Claude Code, type:  /generate-image a cat wearing a hat"
Write-Host ""
Write-Host "  Installed files:" -ForegroundColor White
Write-Host "    Script : $dstScript"
Write-Host "    Config : $configFile"
Write-Host "    Command: $dstCmd"
Write-Host ""
Write-Host "  Management:" -ForegroundColor White
Write-Host "    Reconfigure API Key: python $dstScript setup"
Write-Host "    View config:         python $dstScript config --show"
Write-Host "    Uninstall:           Delete $installDir and $dstCmd"
Write-Host ""
