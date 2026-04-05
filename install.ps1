# Copyright (c) 2026 Ryvione. All rights reserved.

$ErrorActionPreference = "Stop"

$InstallDir = Join-Path $env:APPDATA "rpkg"
$BinDir = Join-Path $env:LOCALAPPDATA "Microsoft\WindowsApps"
$WrapperDir = Join-Path $env:USERPROFILE ".rpkg\bin"
$RepoUrl = "https://pkg.ryvione.dev/releases/rpkg-latest.zip"

Write-Host ""
Write-Host "RPKG" -ForegroundColor Cyan -NoNewline
Write-Host " — Ryvione's Package Manager" -ForegroundColor Gray
Write-Host ""

$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
    Write-Host "X Node.js is required but not installed." -ForegroundColor Red
    Write-Host "  Install it from https://nodejs.org (v18+) and re-run this script."
    exit 1
}

$nodeVersion = node -e "process.stdout.write(process.versions.node)"
$nodeMajor = [int]($nodeVersion.Split(".")[0])
if ($nodeMajor -lt 18) {
    Write-Host "X Node.js v18+ required. Found: v$nodeVersion" -ForegroundColor Red
    exit 1
}

Write-Host "  [OK] Node.js v$nodeVersion detected" -ForegroundColor Green

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
New-Item -ItemType Directory -Force -Path $WrapperDir | Out-Null

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (Test-Path (Join-Path $ScriptDir "package.json")) {
    Write-Host "  -> Installing from local source..." -ForegroundColor Cyan
    Copy-Item -Path "$ScriptDir\*" -Destination $InstallDir -Recurse -Force
} else {
    Write-Host "  -> Downloading RPKG..." -ForegroundColor Cyan
    $TempZip = Join-Path $env:TEMP "rpkg-latest.zip"
    Invoke-WebRequest -Uri $RepoUrl -OutFile $TempZip -UseBasicParsing
    Expand-Archive -Path $TempZip -DestinationPath $InstallDir -Force
    Remove-Item $TempZip
}

Write-Host "  -> Creating ryv.cmd wrapper..." -ForegroundColor Cyan

$WrapperPath = Join-Path $WrapperDir "ryv.cmd"
$NodeEntry = Join-Path $InstallDir "bin\ryv.js"

@"
@echo off
node "$NodeEntry" %*
"@ | Set-Content -Path $WrapperPath -Encoding ASCII

$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$WrapperDir*") {
    Write-Host "  -> Adding $WrapperDir to user PATH..." -ForegroundColor Cyan
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$WrapperDir;$UserPath",
        "User"
    )
}

Write-Host ""
Write-Host "  [OK] RPKG installed successfully!" -ForegroundColor Green
Write-Host "  Open a new terminal, then run: " -NoNewline
Write-Host "ryv help" -ForegroundColor Cyan
Write-Host ""
