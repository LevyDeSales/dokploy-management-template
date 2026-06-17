#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$PROJECT_ROOT"/scripts/*.sh
bash -n "$PROJECT_ROOT"/tests/*.sh

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "$PROJECT_ROOT"/scripts/*.sh "$PROJECT_ROOT"/tests/*.sh
fi

"$PROJECT_ROOT/tests/dokploy-context-test.sh"
