# Copyright (c) 2026 Ryvione. All rights reserved.

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "winkit" -ForegroundColor Cyan -NoNewline
Write-Host " — Windows essentials and tweaks..." -ForegroundColor Gray
Write-Host ""

Write-Host "  -> Installing PowerToys..." -ForegroundColor Cyan
winget install --id Microsoft.PowerToys -e --accept-source-agreements --accept-package-agreements --silent

Write-Host "  -> Installing Windows Terminal..." -ForegroundColor Cyan
winget install --id Microsoft.WindowsTerminal -e --accept-source-agreements --accept-package-agreements --silent

Write-Host "  -> Installing 7-Zip..." -ForegroundColor Cyan
winget install --id 7zip.7zip -e --accept-source-agreements --accept-package-agreements --silent

Write-Host "  -> Installing VLC..." -ForegroundColor Cyan
winget install --id VideoLAN.VLC -e --accept-source-agreements --accept-package-agreements --silent

Write-Host "  -> Installing Notepad++..." -ForegroundColor Cyan
winget install --id Notepad++.Notepad++ -e --accept-source-agreements --accept-package-agreements --silent

Write-Host "  -> Applying system tweaks..." -ForegroundColor Cyan

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f | Out-Null

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f | Out-Null

powercfg /change standby-timeout-ac 0

Write-Host "  -> Enabling Developer Mode..." -ForegroundColor Cyan
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v AllowDevelopmentWithoutDevLicense /d 1 | Out-Null

Write-Host ""
Write-Host "  [OK] winkit installed successfully!" -ForegroundColor Green
Write-Host "  Tip: Restart Explorer or log out to apply all tweaks." -ForegroundColor Yellow
Write-Host ""
