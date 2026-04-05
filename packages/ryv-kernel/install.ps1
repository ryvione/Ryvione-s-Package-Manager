$ErrorActionPreference = "Stop"
Write-Host "`nryv-kernel — ryvionOS terminal simulator`n"

$BinDir = "$env:USERPROFILE\.rpkg\bin"
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

Write-Host "  Downloading ryv-kernel for Windows..."
Invoke-WebRequest "https://pkg.ryvione.dev/kits/ryv-kernel/bin/win" -OutFile "$BinDir\ryv-kernel.exe" -UseBasicParsing

Write-Host "`n✓ ryv-kernel installed!`n"
Write-Host "  Run: ryv-kernel"
Write-Host "  Run: ryv-kernel --no-boot`n"