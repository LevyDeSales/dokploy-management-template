#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/dokploy-env.sh
source "$SCRIPT_DIR/dokploy-env.sh"

if [ "$#" -lt 2 ]; then
  echo "Usage: scripts/dokploy-cli.sh <alltius|zapix> <dokploy command...>" >&2
  exit 2
fi

org="$1"
shift

case "$org" in
  alltius)
    export DOKPLOY_API_KEY="${DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY:?DOKPLOY_ALLTIUS_ORG_ALLTIUS_API_KEY is required}"
    ;;
  zapix)
    export DOKPLOY_API_KEY="${DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY:?DOKPLOY_ALLTIUS_ORG_ZAPIX_API_KEY is required}"
    ;;
  *)
    echo "Unknown org '$org'. Use 'alltius' or 'zapix'." >&2
    exit 2
    ;;
esac

exec npx -y @dokploy/cli@latest "$@"
