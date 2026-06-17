#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

failures=0

fail() {
  printf 'not ok - %s\n' "$1" >&2
  failures=$((failures + 1))
}

pass() {
  printf 'ok - %s\n' "$1"
}

assert_eq() {
  local name="$1"
  local actual="$2"
  local expected="$3"

  if [ "$actual" = "$expected" ]; then
    pass "$name"
  else
    fail "$name: expected '$expected', got '$actual'"
  fi
}

reset_dokploy_env() {
  unset DOKPLOY_CONTEXT
  unset DOKPLOY_CONTEXT_ENV
  unset DOKPLOY_CONTEXTS
  unset DOKPLOY_CONTEXT_ORG_A_API_KEY
  unset DOKPLOY_CONTEXT_ORG_B_API_KEY
  unset DOKPLOY_CONTEXT_PROD_API_KEY
  unset DOKPLOY_CONTEXT_CUSTOMER_PROD_API_KEY
  unset DOKPLOY_CONTEXT_READ_ONLY_API_KEY
  unset DOKPLOY_API_KEY
}

# shellcheck source=../scripts/dokploy-context.sh
source "$PROJECT_ROOT/scripts/dokploy-context.sh"

reset_dokploy_env
assert_eq "normalizes hyphenated context names" "$(normalize_context "customer-prod")" "CUSTOMER_PROD"
assert_eq "normalizes dotted context names" "$(normalize_context "read.only")" "READ_ONLY"

reset_dokploy_env
assert_eq "defaults to example contexts" "$(available_contexts)" "org-a org-b"

reset_dokploy_env
export DOKPLOY_CONTEXTS="prod customer-prod"
if context_is_declared "customer-prod"; then
  pass "finds declared context"
else
  fail "finds declared context"
fi

reset_dokploy_env
export DOKPLOY_CONTEXTS="prod customer-prod"
if context_is_declared "staging"; then
  fail "rejects undeclared context"
else
  pass "rejects undeclared context"
fi

reset_dokploy_env
export DOKPLOY_CONTEXTS="prod customer-prod"
export DOKPLOY_CONTEXT_CUSTOMER_PROD_API_KEY="raw-test-key"
resolve_dokploy_context "customer-prod"
assert_eq "exports selected context" "$DOKPLOY_CONTEXT" "customer-prod"
assert_eq "exports normalized context name" "$DOKPLOY_CONTEXT_ENV" "CUSTOMER_PROD"
assert_eq "maps selected context API key" "$DOKPLOY_API_KEY" "raw-test-key"

reset_dokploy_env
export DOKPLOY_CONTEXTS="prod"
if resolve_dokploy_context "missing" >/tmp/dokploy-context-test.err 2>&1; then
  fail "unknown context exits nonzero"
else
  assert_eq "unknown context exits with code 2" "$?" "2"
fi

reset_dokploy_env
export DOKPLOY_CONTEXTS="prod"
if resolve_dokploy_context "prod" >/tmp/dokploy-context-test.err 2>&1; then
  fail "missing API key exits nonzero"
else
  assert_eq "missing API key exits with code 2" "$?" "2"
fi

if [ "$failures" -ne 0 ]; then
  printf '%s test failure(s)\n' "$failures" >&2
  exit 1
fi
