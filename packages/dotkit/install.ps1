# Copyright (c) 2026 Ryvione. All rights reserved.

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "dotkit" -ForegroundColor Cyan -NoNewline
Write-Host " — Setting up shell config and dotfiles..." -ForegroundColor Gray
Write-Host ""

Write-Host "  -> Installing Oh My Posh..." -ForegroundColor Cyan
winget install --id JanDeDobbeleer.OhMyPosh -e --accept-source-agreements --accept-package-agreements --silent

Write-Host "  -> Installing Neovim..." -ForegroundColor Cyan
winget install --id Neovim.Neovim -e --accept-source-agreements --accept-package-agreements --silent

$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
}

Write-Host "  -> Writing PowerShell profile..." -ForegroundColor Cyan
$profileContent = @'
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression

Set-Alias ll Get-ChildItem
Set-Alias gs git
function .. { Set-Location .. }
function ... { Set-Location ../.. }

$env:EDITOR = "nvim"
'@

Set-Content -Path $PROFILE -Value $profileContent -Encoding UTF8

Write-Host "  -> Writing Neovim config..." -ForegroundColor Cyan
$nvimConfigDir = Join-Path $env:LOCALAPPDATA "nvim"
New-Item -ItemType Directory -Force -Path $nvimConfigDir | Out-Null
$nvimConfig = @'
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.hlsearch = true
vim.opt.termguicolors = true
'@
Set-Content -Path (Join-Path $nvimConfigDir "init.lua") -Value $nvimConfig -Encoding UTF8

Write-Host ""
Write-Host "  [OK] dotkit installed successfully!" -ForegroundColor Green
Write-Host "  Tip: Restart your terminal to apply changes." -ForegroundColor Yellow
Write-Host ""
