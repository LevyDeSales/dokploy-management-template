#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -f "$PROJECT_ROOT/.env.local" ]; then
  set -a
  # Treat .env.local as trusted local shell input. It must stay untracked.
  # shellcheck source=/dev/null
  source "$PROJECT_ROOT/.env.local"
  set +a
fi

require_dokploy_env() {
  if [ -z "${DOKPLOY_URL:-}" ]; then
    echo "DOKPLOY_URL is required. Copy .env.example to .env.local and set your Dokploy panel URL." >&2
    return 2
  fi

  if [ -z "${DOKPLOY_CONTEXTS:-}" ]; then
    echo "DOKPLOY_CONTEXTS is required. Set one or more context slugs in .env.local." >&2
    return 2
  fi

  export DOKPLOY_URL
}

export DOKPLOY_CLI_VERSION="${DOKPLOY_CLI_VERSION:-0.29.4}"
export DOKPLOY_MCP_VERSION="${DOKPLOY_MCP_VERSION:-0.29.3}"

if [ -n "${DOKPLOY_CUSTOM_HEADERS:-}" ]; then
  export DOKPLOY_CUSTOM_HEADERS="$DOKPLOY_CUSTOM_HEADERS"
fi
