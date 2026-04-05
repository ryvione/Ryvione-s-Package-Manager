# Copyright (c) 2026 Ryvione. All rights reserved.

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "syskit" -ForegroundColor Cyan -NoNewline
Write-Host " — Installing system utilities..." -ForegroundColor Gray
Write-Host ""

function Install-WingetPkg($id) {
    Write-Host "  -> Installing $id..." -ForegroundColor Cyan
    winget install --id $id -e --accept-source-agreements --accept-package-agreements --silent
}

$packages = @(
    "Neofetch.Neofetch",
    "gerardog.gsudo",
    "gokcehan.lf",
    "jftuga.less",
    "sharkdp.bat",
    "BurntSushi.ripgrep.MSVC",
    "sharkdp.fd"
)

foreach ($pkg in $packages) {
    try {
        Install-WingetPkg $pkg
    } catch {
        Write-Host "  [WARN] Could not install $pkg : $_" -ForegroundColor Yellow
    }
}

Write-Host "  -> Installing Scoop package manager..." -ForegroundColor Cyan
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
}

Write-Host ""
Write-Host "  [OK] syskit installed successfully!" -ForegroundColor Green
Write-Host ""
