#!/usr/bin/env bash
set -euo pipefail

# Petit lanceur Bash pour le script Python d'audit.
# Usage:
#   ./scripts/diag_reseau.sh
#   ./scripts/diag_reseau.sh --scan --max-scan-hosts 16 --target 192.168.1.1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$SCRIPT_DIR/net_health_audit.py" "$@"
