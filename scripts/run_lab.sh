#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HEALTH_URL="${HEALTH_URL:-http://127.0.0.1:8000/health}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-30}"

if ! [[ "$MAX_ATTEMPTS" =~ ^[0-9]+$ ]] || [[ "$MAX_ATTEMPTS" -le 0 ]]; then
    echo "Erreur : MAX_ATTEMPTS doit être un entier strictement positif." >&2
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "Erreur : curl est requis pour vérifier l'API." >&2
    exit 1
fi

"$PROJECT_ROOT/scripts/compose.sh" -f "$PROJECT_ROOT/compose.yaml" up -d --build

echo "Attente de l'API sur $HEALTH_URL (max ${MAX_ATTEMPTS}s) ..."

for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
    if curl -fsS --max-time 2 "$HEALTH_URL" >/dev/null 2>&1; then
        echo "API disponible : $HEALTH_URL"
        exit 0
    fi

    if [[ "$attempt" -eq "$MAX_ATTEMPTS" ]]; then
        break
    fi

    sleep 1
done

echo "Erreur : l'API ne répond pas après ${MAX_ATTEMPTS} secondes." >&2
"$PROJECT_ROOT/scripts/compose.sh" -f "$PROJECT_ROOT/compose.yaml" ps >&2 || true
exit 1
