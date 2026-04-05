# Copyright (c) 2026 Ryvione. All rights reserved.

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "gamerkit" -ForegroundColor Cyan -NoNewline
Write-Host " — Installing gaming tools..." -ForegroundColor Gray
Write-Host ""

function Install-WingetPkg($id) {
    Write-Host "  -> Installing $id..." -ForegroundColor Cyan
    winget install --id $id -e --accept-source-agreements --accept-package-agreements --silent
}

$packages = @(
    "Valve.Steam",
    "Discord.Discord",
    "Parsec.Parsec",
    "EpicGames.EpicGamesLauncher"
)

foreach ($pkg in $packages) {
    try {
        Install-WingetPkg $pkg
    } catch {
        Write-Host "  [WARN] Could not install $pkg : $_" -ForegroundColor Yellow
    }
}

Write-Host "  -> Applying gaming performance tweaks..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38
powercfg -setactive SCHEME_MIN

Write-Host ""
Write-Host "  [OK] gamerkit installed successfully!" -ForegroundColor Green
Write-Host "  Tip: Restart your PC to apply performance tweaks." -ForegroundColor Yellow
Write-Host ""
