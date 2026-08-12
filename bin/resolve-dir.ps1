#!/usr/bin/env pwsh
# bin/resolve-dir.ps1
# Windows equivalent of resolve-dir.sh

# Priority 1: Explicit argument
if ($args.Count -gt 0) {
    Write-Host $args[0]
    exit 0
}

# Priority 2: HERDR_EXPLORER_DIR env var
if ($env:HERDR_EXPLORER_DIR) {
    Write-Host $env:HERDR_EXPLORER_DIR
    exit 0
}

# Priority 3: HERDR_PLUGIN_CONTEXT_JSON
if ($env:HERDR_PLUGIN_CONTEXT_JSON) {
    $ctx = $env:HERDR_PLUGIN_CONTEXT_JSON | ConvertFrom-Json
    $dir = $ctx.focused_pane_cwd ?? $ctx.workspace_cwd
    if ($dir) {
        Write-Host $dir
        exit 0
    }
}

# Priority 4: Current directory
$pwd = (Get-Location).Path
Write-Host $pwd