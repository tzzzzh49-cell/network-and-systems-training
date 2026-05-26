#!/usr/bin/env bash

# Script de diagnostic local pour le projet voice-controlled-network-lab.
# Objectif : observer l'état du système et générer un rapport Markdown.
# Ce script ne modifie rien sur la machine.

set -u

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$PROJECT_ROOT/outputs/reports"
TIMESTAMP="$(date +"%Y-%m-%d-%H%M%S")"
REPORT_FILE="$REPORT_DIR/diagnostic-$TIMESTAMP.md"
API_HEALTH_URL="${API_HEALTH_URL:-http://127.0.0.1:8000/health}"

mkdir -p "$REPORT_DIR"

DOCKER_STATUS="KO"
DOCKER_DETAILS="Docker non testé."

API_STATUS="KO"
API_DETAILS="API non testée."

sanitize_markdown_cell() {
    echo "$1" | tr '\n' ' ' | sed 's/|/\\|/g'
}

check_docker() {
    local docker_out docker_err
    docker_out="$(mktemp)"
    docker_err="$(mktemp)"

    if ! command -v docker >/dev/null 2>&1; then
        DOCKER_STATUS="KO"
        DOCKER_DETAILS="La commande docker est introuvable."
        rm -f "$docker_out" "$docker_err"
        return
    fi

    if timeout 5 docker ps >"$docker_out" 2>"$docker_err"; then
        DOCKER_STATUS="OK"
        DOCKER_DETAILS="Docker répond correctement à la commande docker ps."
    else
        DOCKER_STATUS="KO"
        DOCKER_DETAILS="$(sanitize_markdown_cell "$(cat "$docker_err" 2>/dev/null)")"
    fi

    rm -f "$docker_out" "$docker_err"
}

check_api() {
    if ! command -v curl >/dev/null 2>&1; then
        API_STATUS="KO"
        API_DETAILS="La commande curl est introuvable."
        return
    fi

    local body_file
    local err_file
    local http_code

    body_file="$(mktemp)"
    err_file="$(mktemp)"

    http_code="$(curl -sS --max-time 3 -o "$body_file" -w "%{http_code}" "$API_HEALTH_URL" 2>"$err_file" || true)"

    if [[ "$http_code" == "200" ]]; then
        API_STATUS="OK"
        API_DETAILS="L'API répond correctement avec le code HTTP 200."
    else
        API_STATUS="KO"
        API_DETAILS="L'API ne répond pas correctement. Code HTTP : $http_code. Erreur : $(sanitize_markdown_cell "$(cat "$err_file")")"
    fi

    rm -f "$body_file" "$err_file"
}

write_title() {
    {
      echo "# Rapport de diagnostic local"
      echo
      echo "Date du diagnostic : $(date)"
      echo
      echo "Projet : voice-controlled-network-lab"
      echo
    } >"$REPORT_FILE"
}

write_summary() {
    {
      echo "## Synthèse rapide"
      echo
      echo "| Élément | Statut | Détail |"
      echo "|---|---|---|"
      echo "| Docker | $DOCKER_STATUS | $(sanitize_markdown_cell "$DOCKER_DETAILS") |"
      echo "| API /health | $API_STATUS | $(sanitize_markdown_cell "$API_DETAILS") |"
      echo
    } >>"$REPORT_FILE"
}

write_section() {
    local title="$1"
    shift

    {
      echo
      echo "## $title"
      echo
      echo "Commande exécutée :"
      echo
      echo "    $*"
      echo
      echo "Résultat :"
      echo

      if command -v "$1" >/dev/null 2>&1; then
          "$@" 2>&1 || true
      else
          echo "Commande introuvable : $1"
      fi
    } >>"$REPORT_FILE"
}

write_health_check() {
    {
      echo
      echo "## Test détaillé de l'API locale"
      echo
      echo "URL testée :"
      echo
      echo "    $API_HEALTH_URL"
      echo
      echo "Résultat :"
      echo

      if command -v curl >/dev/null 2>&1; then
          curl -sS --max-time 3 "$API_HEALTH_URL" 2>&1 || true
      else
          echo "Commande introuvable : curl"
      fi

      echo
    } >>"$REPORT_FILE"
}

write_conclusion() {
    {
      echo
      echo "## Conclusion"
      echo

      if [[ "$DOCKER_STATUS" == "OK" && "$API_STATUS" == "OK" ]]; then
          echo "Conclusion : Docker fonctionne et l'API répond correctement."
      elif [[ "$DOCKER_STATUS" == "OK" && "$API_STATUS" == "KO" ]]; then
          echo "Conclusion : Docker fonctionne, mais l'API ne répond pas correctement."
      elif [[ "$DOCKER_STATUS" == "KO" && "$API_STATUS" == "OK" ]]; then
          echo "Conclusion : l'API répond, mais Docker ne fonctionne pas correctement."
      else
          echo "Conclusion : Docker et l'API semblent en erreur ou indisponibles."
      fi

      echo
      echo "Rapport généré ici :"
      echo
      echo "    $REPORT_FILE"
    } >>"$REPORT_FILE"
}

check_docker
check_api

write_title
write_summary

write_section "Nom de la machine" hostname
write_section "Informations système" uname -a
write_section "Interfaces réseau" ip a
write_section "Routes réseau" ip route
write_section "Ports ouverts" ss -tulpn
write_section "Espace disque" df -h
write_section "Mémoire" free -h
write_section "Conteneurs Docker" timeout 5 docker ps

write_health_check
write_conclusion

echo "Diagnostic terminé."
echo "Docker : $DOCKER_STATUS"
echo "API : $API_STATUS"
echo "Rapport généré : $REPORT_FILE"
