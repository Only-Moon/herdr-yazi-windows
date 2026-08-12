#!/usr/bin/env pwsh
# scripts/open-yazi-tab-windows.ps1
# Windows launcher for yazi new tab - with version detection & fallback

$ErrorActionPreference = 'Continue'

# Force UTF-8 encoding
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = $Utf8NoBom
$OutputEncoding = $Utf8NoBom

$HerdrBin = if ($env:HERDR_BIN_PATH) { $env:HERDR_BIN_PATH } else { 'herdr' }

# Check if herdr version supports native Windows pane spawning (v0.8.0+)
function Test-NativePaneSupport {
    try {
        $verOutput = & $HerdrBin --version 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $verOutput) { return $false }
        
        if ($verOutput -match 'herdr\s+(\d+)\.(\d+)\.(\d+)') {
            $major = [int]$matches[1]
            $minor = [int]$matches[2]
            $patch = [int]$matches[3]
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
    # Native: plugin pane open with tab placement
    & $HerdrBin plugin pane open --plugin ray.file-explorer --entrypoint explorer --placement tab --cwd $cwd
    
    # Set tab name to "yazi"
    Start-Sleep -Milliseconds 500
    & $HerdrBin tab rename "yazi" *>$null
} else {
    # Fallback: tab create + pane run
    $tabArgs = @('tab', 'create', '--cwd', $cwd, '--focus')
    $out = & $HerdrBin @tabArgs 2>&1
    $tabId = ([regex]'"tab_id":"([^"]+)"').Match($out).Groups[1].Value
    if ($tabId) {
        $data = $out | ConvertFrom-Json
        $paneId = $data.result.root_pane.pane_id
        if ($paneId) {
            Start-Sleep -Milliseconds 3000
            & $HerdrBin pane run $paneId "yazi"
            Start-Sleep -Milliseconds 1000
            & $HerdrBin pane send-keys $paneId Enter
            & $HerdrBin pane rename $paneId "Yazi" *>$null
            & $HerdrBin tab rename "yazi" *>$null
        }
    }
}

exit 0