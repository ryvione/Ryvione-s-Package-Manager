# Copyright (c) 2026 Ryvione. All rights reserved.

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "devkit" -ForegroundColor Cyan -NoNewline
Write-Host " — Installing developer tools..." -ForegroundColor Gray
Write-Host ""

function Install-WingetPkg($id) {
    Write-Host "  -> Installing $id..." -ForegroundColor Cyan
    winget install --id $id -e --accept-source-agreements --accept-package-agreements --silent
}

$packages = @(
    "Git.Git",
    "vim.vim",
    "cURL.cURL",
    "Neovim.Neovim",
    "Microsoft.WindowsTerminal",
    "OpenJS.NodeJS.LTS"
)

foreach ($pkg in $packages) {
    try {
        Install-WingetPkg $pkg
    } catch {
        Write-Host "  [WARN] Could not install $pkg : $_" -ForegroundColor Yellow
    }
}

$gitPath = "C:\Program Files\Git\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notlike "*$gitPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$gitPath", "Machine")
}

Write-Host ""
Write-Host "  [OK] devkit installed successfully!" -ForegroundColor Green
Write-Host ""
