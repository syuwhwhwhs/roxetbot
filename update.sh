#!/usr/bin/env bash
# Compatibility wrapper — use: bash roxet.sh
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "${SCRIPT_DIR}/roxet.sh" update
