#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/dokploy-context.sh
source "$SCRIPT_DIR/dokploy-context.sh"

resolve_dokploy_context "org-b"
export DOKPLOY_ENABLED_TAGS="${DOKPLOY_ENABLED_TAGS:-project,environment,application,compose,domain,deployment,postgres,redis,server,settings,backup,notification,organization}"
export DOKPLOY_REDACT_ENV="${DOKPLOY_REDACT_ENV:-true}"
export DOKPLOY_TIMEOUT="${DOKPLOY_TIMEOUT:-30000}"
export DOKPLOY_RETRY_ATTEMPTS="${DOKPLOY_RETRY_ATTEMPTS:-2}"
export DOKPLOY_RETRY_DELAY="${DOKPLOY_RETRY_DELAY:-1000}"

exec npx -y --package @dokploy/mcp@latest dokploy-mcp
