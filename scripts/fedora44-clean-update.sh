#!/usr/bin/env bash
set -Eeuo pipefail

# fedora44-clean-update.sh
# Script de mise à jour propre pour Fedora 44 Workstation.
# Objectif : rendre les opérations explicites, journalisées et prudentes.

SCRIPT_NAME="$(basename "$0")"
LOG_DIR="/var/log/clean-system-update"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${LOG_DIR}/fedora44-update-${TIMESTAMP}.log"

DRY_RUN=false
ASSUME_YES=false
NO_CLEAN=false
NO_REBOOT_CHECK=false
INCLUDE_FLATPAK=false
INCLUDE_FIRMWARE=false
REBOOT_AFTER=false

DNF_CMD=""
UPDATED_PACKAGES_FILE="/tmp/fedora-updated-packages-${TIMESTAMP}.txt"

usage() {
  cat <<USAGE
Usage: $SCRIPT_NAME [options]

Options:
  --dry-run            Affiche les commandes sans les exécuter
  --yes                Accepte automatiquement les confirmations
  --no-clean           Désactive autoremove/clean
  --no-reboot-check    Ignore l'analyse de recommandation reboot
  --include-flatpak    Met à jour Flatpak (si installé)
  --include-firmware   Lance fwupdmgr refresh/update (si installé)
  --reboot             Redémarre explicitement en fin de traitement
  -h, --help           Affiche cette aide
USAGE
}

log() { echo "[$(date +'%F %T')] $*"; }

run_cmd() {
  local cmd=("$@")
  if $DRY_RUN; then
    log "[DRY-RUN] ${cmd[*]}"
  else
    log "[RUN] ${cmd[*]}"
    "${cmd[@]}"
  fi
}

confirm() {
  local prompt="$1"
  if $ASSUME_YES; then
    return 0
  fi
  read -r -p "$prompt [y/N]: " ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

require_root() {
  if [[ "$EUID" -ne 0 ]]; then
    echo "Ce script doit être exécuté en root (ou via sudo)." >&2
    exit 1
  fi
}

setup_logging() {
  mkdir -p "$LOG_DIR"
  touch "$LOG_FILE"
  exec > >(tee -a "$LOG_FILE") 2>&1
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) DRY_RUN=true ;;
      --yes) ASSUME_YES=true ;;
      --no-clean) NO_CLEAN=true ;;
      --no-reboot-check) NO_REBOOT_CHECK=true ;;
      --include-flatpak) INCLUDE_FLATPAK=true ;;
      --include-firmware) INCLUDE_FIRMWARE=true ;;
      --reboot) REBOOT_AFTER=true ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Option inconnue: $1" >&2; usage; exit 1 ;;
    esac
    shift
  done
}

check_os() {
  source /etc/os-release
  if [[ "${ID:-}" != "fedora" || "${VERSION_ID:-}" != "44" ]]; then
    echo "Distribution non supportée. Attendu: Fedora 44." >&2
    exit 1
  fi
}

select_dnf() {
  if command -v dnf5 >/dev/null 2>&1; then
    DNF_CMD="dnf5"
  elif command -v dnf >/dev/null 2>&1; then
    DNF_CMD="dnf"
  else
    echo "Ni dnf ni dnf5 ne sont disponibles." >&2
    exit 1
  fi
}

check_network() {
  log "Vérification réseau..."
  run_cmd ping -c 1 -W 2 1.1.1.1
}

check_disk() {
  log "Vérification espace disque pour /, /boot et /var"
  run_cmd df -h /
  run_cmd df -h /boot
  run_cmd df -h /var
}

print_summary_before_changes() {
  cat <<EOF_SUM
Résumé avant actions:
  - Distribution: Fedora 44
  - Commande dnf détectée: $DNF_CMD
  - Dry-run: $DRY_RUN
  - Auto-confirmation: $ASSUME_YES
  - Nettoyage désactivé: $NO_CLEAN
  - Flatpak: $INCLUDE_FLATPAK
  - Firmware: $INCLUDE_FIRMWARE
  - Redémarrage auto explicite: $REBOOT_AFTER
  - Log: $LOG_FILE
EOF_SUM
}

list_updates() {
  log "Liste des mises à jour disponibles"
  if $DRY_RUN; then
    log "[DRY-RUN] $DNF_CMD check-update"
  else
    set +e
    "$DNF_CMD" check-update
    local rc=$?
    set -e
    if [[ $rc -ne 0 && $rc -ne 100 ]]; then
      log "Erreur check-update (code $rc)"
      exit $rc
    fi
  fi
}

perform_update() {
  run_cmd "$DNF_CMD" -y upgrade --refresh
  if ! $DRY_RUN; then
    "$DNF_CMD" history info last | sed -n '/Packages Altered:/,$p' > "$UPDATED_PACKAGES_FILE" || true
  fi
}

optional_updates() {
  if $INCLUDE_FLATPAK && command -v flatpak >/dev/null 2>&1; then
    run_cmd flatpak update -y
  fi

  if $INCLUDE_FIRMWARE && command -v fwupdmgr >/dev/null 2>&1; then
    run_cmd fwupdmgr refresh --force
    run_cmd fwupdmgr update -y
  fi
}

cleanup_steps() {
  $NO_CLEAN && return

  log "Paquets candidats à autoremove:"
  run_cmd "$DNF_CMD" repoquery --unneeded

  if confirm "Exécuter autoremove ?"; then
    run_cmd "$DNF_CMD" -y autoremove
  else
    log "Autoremove ignoré."
  fi

  log "Nettoyage prudent du cache DNF (dnf clean packages)"
  if confirm "Exécuter le nettoyage du cache DNF ?"; then
    run_cmd "$DNF_CMD" clean packages
  else
    log "Nettoyage cache ignoré."
  fi
}

reboot_advice() {
  $NO_REBOOT_CHECK && return
  local trigger_regex='(^| )(kernel|systemd|glibc|mesa|linux-firmware|intel-microcode|amd-ucode|nvidia)( |$)'
  if [[ -f "$UPDATED_PACKAGES_FILE" ]] && grep -Eiq "$trigger_regex" "$UPDATED_PACKAGES_FILE"; then
    log "Reboot recommandé: composants sensibles mis à jour (kernel/systemd/glibc/mesa/firmware/microcode/driver)."
  else
    log "Aucune mise à jour critique détectée pour reboot immédiat."
  fi
}

maybe_reboot() {
  if $REBOOT_AFTER; then
    if confirm "Redémarrer maintenant ?"; then
      run_cmd systemctl reboot
    fi
  else
    log "Aucun redémarrage automatique (utilisez --reboot si souhaité)."
  fi
}

main() {
  parse_args "$@"
  require_root
  setup_logging
  check_os
  select_dnf
  print_summary_before_changes

  if ! $ASSUME_YES && ! confirm "Continuer avec les opérations de mise à jour ?"; then
    log "Annulé par l'utilisateur."
    exit 0
  fi

  check_network
  check_disk
  list_updates
  perform_update
  optional_updates
  cleanup_steps
  reboot_advice
  maybe_reboot

  log "Terminé. Journal: $LOG_FILE"
}

main "$@"
