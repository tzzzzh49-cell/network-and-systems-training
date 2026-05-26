#!/usr/bin/env bash

set -euo pipefail

find_compose_cmd() {
    if docker ps >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        COMPOSE_CMD=(docker compose)
        return
    fi

    if docker ps >/dev/null 2>&1 && command -v docker-compose >/dev/null 2>&1 && docker-compose version >/dev/null 2>&1; then
        COMPOSE_CMD=(docker-compose)
        return
    fi

    if command -v sudo >/dev/null 2>&1 && sudo -n docker ps >/dev/null 2>&1 && sudo -n docker compose version >/dev/null 2>&1; then
        COMPOSE_CMD=(sudo -n docker compose)
        return
    fi

    if command -v sudo >/dev/null 2>&1 && command -v docker-compose >/dev/null 2>&1 && sudo -n docker ps >/dev/null 2>&1 && sudo -n docker-compose version >/dev/null 2>&1; then
        COMPOSE_CMD=(sudo -n docker-compose)
        return
    fi

    echo "Erreur : Docker Compose est introuvable ou Docker n'est pas accessible." >&2
    echo "Sur Fedora 44, lance d'abord : ./scripts/bootstrap_fedora44_vm.sh" >&2
    exit 1
}

if [[ "$#" -eq 0 ]]; then
    echo "Usage: $0 <arguments docker compose>" >&2
    echo "Exemple: $0 -f compose.yaml up -d" >&2
    exit 1
fi

COMPOSE_CMD=()
find_compose_cmd

exec "${COMPOSE_CMD[@]}" "$@"
