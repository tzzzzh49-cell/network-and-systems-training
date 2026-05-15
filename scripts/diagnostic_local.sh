#!/usr/bin/env bash

# Script de diagnostic local pour le projet voice-controlled-network-lab.
# Objectif : observer l'état du système et générer un rapport Markdown.
# Ce script ne doit rien modifier sur la machine.

set -u

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$PROJECT_ROOT/outputs/reports"
TIMESTAMP="$(date +"%Y-%m-%d-%H%M%S")"
REPORT_FILE="$REPORT_DIR/diagnostic-$TIMESTAMP.md"
API_HEALTH_URL="${API_HEALTH_URL:-http://127.0.0.1:8000/health}"

mkdir -p "$REPORT_DIR"

write_title() {
    echo "# Rapport de diagnostic local" > "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "Date du diagnostic : $(date)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "Projet : voice-controlled-network-lab" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
}

write_section() {
    local title="$1"
    shift

    echo "" >> "$REPORT_FILE"
    echo "## $title" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "Commande exécutée :" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "    $*" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "Résultat :" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    if command -v "$1" >/dev/null 2>&1; then
        "$@" >> "$REPORT_FILE" 2>&1 || true
    else
        echo "Commande introuvable : $1" >> "$REPORT_FILE"
    fi
}

write_health_check() {
    echo "" >> "$REPORT_FILE"
    echo "## Test de l'API locale" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "URL testée :" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "    $API_HEALTH_URL" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "Résultat :" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    if command -v curl >/dev/null 2>&1; then
        curl -sS --max-time 3 "$API_HEALTH_URL" >> "$REPORT_FILE" 2>&1 || true
    else
        echo "Commande introuvable : curl" >> "$REPORT_FILE"
    fi

    echo "" >> "$REPORT_FILE"
}

write_summary() {
    echo "" >> "$REPORT_FILE"
    echo "## Conclusion" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "Ce rapport est une photographie de l'état local de la machine au moment du diagnostic." >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "Il sert de preuve d'état avant ou après un changement." >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "Rapport généré ici :" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "    $REPORT_FILE" >> "$REPORT_FILE"
}

write_title

write_section "Nom de la machine" hostname
write_section "Informations système" uname -a
write_section "Interfaces réseau" ip a
write_section "Routes réseau" ip route
write_section "Ports ouverts" ss -tulpn
write_section "Espace disque" df -h
write_section "Mémoire" free -h
write_section "Conteneurs Docker" docker ps

write_health_check
write_summary

echo "Diagnostic terminé."
echo "Rapport généré : $REPORT_FILE"
