#!/usr/bin/env pwsh
# scripts/open-yazi-windows.ps1
# Windows launcher for yazi split pane - with version detection & fallback

$ErrorActionPreference = 'Continue'

# Force UTF-8 encoding
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = $Utf8NoBom
$OutputEncoding = $Utf8NoBom

$HerdrBin = if ($env:HERDR_BIN_PATH) { $env:HERDR_BIN_PATH } else { 'herdr' }

function Strip-Verbatim([string]$p) {
    if ($p -and $p.StartsWith('\\?\')) { return $p.Substring(4) }
    return $p
}

# Check if herdr version supports native Windows pane spawning (v0.8.0+)
function Test-NativePaneSupport {
    try {
        $verOutput = & $HerdrBin --version 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $verOutput) { return $false }
        
        # Parse version like "herdr 0.8.0-preview.2026-08-04-d78e3d3b5126"
        if ($verOutput -match 'herdr\s+(\d+)\.(\d+)\.(\d+)') {
            $major = [int]$matches[1]
            $minor = [int]$matches[2]
            $patch = [int]$matches[3]
            # Native Windows pane support added in v0.8.0
            return ($major -gt 0) -or ($major -eq 0 -and $minor -ge 8)
        }
    } catch {}
    return $false
}

# Get focused pane's cwd
function Get-UserCwd {
    $HerdrBin = if ($env:HERDR_BIN_PATH) { $env:HERDR_BIN_PATH } else { 'herdr' }
    try {
        $focused = (& $HerdrBin pane list 2>$null | ConvertFrom-Json).result.panes |
            Where-Object { $_.focused } | Select-Object -First 1
        if ($focused -and $focused.cwd) { return $focused.cwd }
    } catch {}
    return (Get-Location).Path
}

$cwd = Get-UserCwd

# Check for native pane support (v0.8.0+)
$hasNativeSupport = Test-NativePaneSupport

if ($hasNativeSupport) {
    # Native: plugin pane open spawns yazi directly as pane PID 1
    & $HerdrBin plugin pane open --plugin ray.file-explorer --entrypoint explorer --placement split --cwd $cwd
} else {
    # Fallback: pane split + pane run (old workaround)
    $splitArgs = @('pane', 'split', '--direction', 'right', '--cwd', $cwd, '--focus')
    $out = & $HerdrBin @splitArgs 2>&1
    $paneId = ([regex]'"pane_id":"([^"]+)"').Match($out).Groups[1].Value
    if ($paneId) {
        Start-Sleep -Milliseconds 2000
        & $HerdrBin pane run $paneId "yazi"
        Start-Sleep -Milliseconds 1000
        & $HerdrBin pane send-keys $paneId Enter
        & $HerdrBin pane rename $paneId "Yazi" *>$null
    }
}

exit 0