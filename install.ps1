# Copyright (c) 2026 Ryvione. All rights reserved.

$ErrorActionPreference = "Stop"

$InstallDir = Join-Path $env:APPDATA "rpkg"
$WrapperDir = Join-Path $env:USERPROFILE ".rpkg\bin"
$Repo = "https://github.com/ryvione/Ryvione-s-Package-Manager"

Write-Host ""
Write-Host "RPKG" -ForegroundColor Cyan -NoNewline
Write-Host " — Ryvione's Package Manager" -ForegroundColor Gray
Write-Host ""

function Skip($msg) { Write-Host "  [SKIP] $msg already installed, skipping" -ForegroundColor Yellow }
function Ok($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Step($msg) { Write-Host "  [->] $msg" -ForegroundColor Cyan }
function Fail($msg) { Write-Host "  [X] $msg" -ForegroundColor Red }

$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
    Fail "Node.js is required but not installed."
    Write-Host "     Install it from https://nodejs.org (v18+) and re-run this script."
    exit 1
}

$nodeVersion = node -e "process.stdout.write(process.versions.node)"
$nodeMajor = [int]($nodeVersion.Split(".")[0])
if ($nodeMajor -lt 18) {
    Fail "Node.js v18+ required. Found: v$nodeVersion"
    exit 1
}

Ok "Node.js v$nodeVersion detected"

New-Item -ItemType Directory -Force -Path $WrapperDir | Out-Null

if (Test-Path (Join-Path $InstallDir ".git")) {
    Skip "RPKG source (pulling latest instead)"
    git -C $InstallDir pull --ff-only --quiet
} elseif (Test-Path (Join-Path $InstallDir "package.json")) {
    Skip "RPKG source (already present)"
} else {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        Step "Cloning RPKG from GitHub..."
        git clone --depth=1 $Repo $InstallDir --quiet
    } else {
        Step "Downloading RPKG from GitHub..."
        $zip = Join-Path $env:TEMP "rpkg-master.zip"
        Invoke-WebRequest "$Repo/archive/refs/heads/master.zip" -OutFile $zip -UseBasicParsing
        Expand-Archive -Path $zip -DestinationPath $env:TEMP -Force
        Move-Item "$env:TEMP\Ryvione-s-Package-Manager-master" $InstallDir -Force
        Remove-Item $zip
    }
}

$wrapperPath = Join-Path $WrapperDir "ryv.cmd"
if (Test-Path $wrapperPath) {
    Skip "ryv.cmd"
} else {
    Step "Creating ryv.cmd wrapper..."
    $nodeEntry = Join-Path $InstallDir "bin\ryv.js"
    "@echo off`nnode `"$nodeEntry`" %*" | Set-Content -Path $wrapperPath -Encoding ASCII
    Ok "ryv linked to $wrapperPath"
}

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -like "*$WrapperDir*") {
    Skip "PATH entry"
} else {
    [Environment]::SetEnvironmentVariable("Path", "$WrapperDir;$userPath", "User")
    Ok "Added $WrapperDir to user PATH"
}

Write-Host ""
Write-Host "  [OK] RPKG ready!" -ForegroundColor Green
Write-Host "  Open a new terminal, then run: " -NoNewline
Write-Host "ryv help" -ForegroundColor Cyan
Write-Host ""