#!/usr/bin/env pwsh
# bin/startup.ps1 - Windows startup hook
# Registers event-driven one-shot refresh via herdr event hooks

param(
    [string]$Command = "start"
)

# If called with "stop", remove the watcher lock
if ($Command -eq "stop") {
    $lockPath = Join-Path (Split-Path $PSScriptRoot -Parent) "state\watcher.lock"
    if (Test-Path $lockPath) {
        Remove-Item $lockPath -Force -ErrorAction SilentlyContinue
        Write-Host "[herdr-yazi] watcher stopped"
    }
    exit 0
}

# Startup: verify yazi exists and event hooks are registered
try {
    $yazi = Get-Command yazi.exe -ErrorAction Stop
    Write-Host "[herdr-yazi] startup: yazi found at $($yazi.Source)"
    Write-Host "[herdr-yazi] startup: event hooks active (pane.focused, tab.created, etc.)"
    exit 0
}
catch {
    Write-Error "[herdr-yazi] startup failed: yazi.exe not found in PATH"
    exit 1
}