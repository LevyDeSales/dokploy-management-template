#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/dokploy-env.sh
source "$SCRIPT_DIR/dokploy-env.sh"

normalize_context() {
  printf '%s' "$1" | tr '[:lower:]' '[:upper:]' | sed 's/[^A-Z0-9]/_/g'
}

available_contexts() {
  if [ -n "${DOKPLOY_CONTEXTS:-}" ]; then
    printf '%s\n' "$DOKPLOY_CONTEXTS"
  else
    printf 'org-a org-b\n'
  fi
}

context_is_declared() {
  local context="$1"
  local declared

  for declared in $(available_contexts); do
    if [ "$declared" = "$context" ]; then
      return 0
    fi
  done

  return 1
}

print_context_usage() {
  local command_name="$1"

  {
    printf 'Usage: %s <context> %s\n' "$command_name" "${2:-}"
    printf 'Available contexts: %s\n' "$(available_contexts)"
    printf 'Context API key variable format: DOKPLOY_CONTEXT_<NORMALIZED_CONTEXT>_API_KEY\n'
  } >&2
}

resolve_dokploy_context() {
  local context="$1"
  local normalized
  local key_var
  local key_value

  if ! context_is_declared "$context"; then
    echo "Unknown Dokploy context '$context'. Available contexts: $(available_contexts)" >&2
    return 2
  fi

  normalized="$(normalize_context "$context")"
  key_var="DOKPLOY_CONTEXT_${normalized}_API_KEY"
  key_value="${!key_var:-}"

  if [ -z "$key_value" ]; then
    echo "$key_var is required for Dokploy context '$context'" >&2
    return 2
  fi

  export DOKPLOY_CONTEXT="$context"
  export DOKPLOY_CONTEXT_ENV="$normalized"
  export DOKPLOY_API_KEY="$key_value"
}
