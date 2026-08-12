#!/usr/bin/env pwsh
# scripts/check-yazi.ps1
# Checks for yazi installation, returns error with install options if missing

$ErrorActionPreference = "Stop"

function Check-Yazi {
    if (Get-Command yazi.exe -ErrorAction SilentlyContinue) {
        $path = (Get-Command yazi.exe).Source
        Write-Host "yazi found: $path"
        return $true
    }
    return $false
}

function Show-InstallOptions {
    Write-Error "yazi not found in PATH."
    Write-Host ""
    Write-Host "Install yazi using one of these methods:"
    Write-Host ""
    Write-Host "  Scoop:     scoop install yazi"
    Write-Host "  Winget:    winget install --id=SXYA.Yazi --silent --accept-source-agreements --accept-package-agreements"
    Write-Host "  Chocolatey: choco install yazi"
    Write-Host "  Manual:    https://github.com/sxyazi/yazi/releases"
    Write-Host ""
    Write-Host "After installing, restart your shell and try again."
}

if (-not (Check-Yazi)) {
    Show-InstallOptions
    exit 1
}

Write-Host "yazi found: $(Get-Command yazi.exe).Source"
exit 0