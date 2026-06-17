#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -f "$PROJECT_ROOT/.env.local" ]; then
  set -a
  # shellcheck source=/dev/null
  source "$PROJECT_ROOT/.env.local"
  set +a
fi

export DOKPLOY_URL="${DOKPLOY_URL:-https://dokploy.example.com}"

if [ -n "${DOKPLOY_CUSTOM_HEADERS:-}" ]; then
  export DOKPLOY_CUSTOM_HEADERS="$DOKPLOY_CUSTOM_HEADERS"
fi
