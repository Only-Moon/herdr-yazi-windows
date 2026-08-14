#!/usr/bin/env bash
set -euo pipefail

if [ -n "${1:-}" ]; then
  printf '%s\n' "$1"
  exit 0
fi
if [ -n "${HERDR_EXPLORER_DIR:-}" ]; then
  printf '%s\n' "$HERDR_EXPLORER_DIR"
  exit 0
fi
if [ -n "${HERDR_PLUGIN_CONTEXT_JSON:-}" ]; then
  DIR="$(HERDR_CTX="$HERDR_PLUGIN_CONTEXT_JSON" python3 - <<'PY'
import json, os
try:
    ctx = json.loads(os.environ.get("HERDR_CTX", "") or "{}")
    d = ctx.get("focused_pane_cwd") or ctx.get("workspace_cwd") or ""
    if isinstance(d, str) and d:
        print(d, end="")
except Exception:
    pass
PY
)"
  if [ -n "$DIR" ]; then
    printf '%s\n' "$DIR"
    exit 0
  fi
fi
pwd