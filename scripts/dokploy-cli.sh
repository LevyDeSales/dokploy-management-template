#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/dokploy-context.sh
source "$SCRIPT_DIR/dokploy-context.sh"

if [ "$#" -lt 2 ]; then
  echo "Usage: scripts/dokploy-cli.sh <context> <dokploy command...>" >&2
  echo "Available contexts: $(available_contexts)" >&2
  exit 2
fi

context="$1"
shift

resolve_dokploy_context "$context"

exec npx -y @dokploy/cli@latest "$@"
