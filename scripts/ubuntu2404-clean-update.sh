#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME="$(basename "$0")"
LOG_DIR="/var/log/clean-system-update"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${LOG_DIR}/ubuntu2404-update-${TIMESTAMP}.log"

DRY_RUN=false
ASSUME_YES=false
NO_CLEAN=false
NO_REBOOT_CHECK=false
INCLUDE_FLATPAK=false
INCLUDE_SNAP=false
INCLUDE_FIRMWARE=false
REBOOT_AFTER=false

usage() {
  cat <<USAGE
Usage: $SCRIPT_NAME [options]
Options: --dry-run --yes --no-clean --no-reboot-check --include-flatpak --include-snap --include-firmware --reboot
USAGE
}

log(){ echo "[$(date +'%F %T')] $*"; }
run_cmd(){ if $DRY_RUN; then log "[DRY-RUN] $*"; else log "[RUN] $*"; "$@"; fi; }
confirm(){ $ASSUME_YES && return 0; read -r -p "$1 [y/N]: " a; [[ "$a" =~ ^[Yy]$ ]]; }

parse_args(){ while [[ $# -gt 0 ]]; do case "$1" in
  --dry-run) DRY_RUN=true;; --yes) ASSUME_YES=true;; --no-clean) NO_CLEAN=true;; --no-reboot-check) NO_REBOOT_CHECK=true;;
  --include-flatpak) INCLUDE_FLATPAK=true;; --include-snap) INCLUDE_SNAP=true;; --include-firmware) INCLUDE_FIRMWARE=true;; --reboot) REBOOT_AFTER=true;;
  -h|--help) usage; exit 0;; *) echo "Option inconnue: $1"; exit 1;; esac; shift; done; }

require_root(){ [[ "$EUID" -eq 0 ]] || { echo "Exécuter en root/sudo."; exit 1; }; }
setup_logging(){ mkdir -p "$LOG_DIR"; touch "$LOG_FILE"; exec > >(tee -a "$LOG_FILE") 2>&1; }
check_os(){ source /etc/os-release; [[ "${ID:-}" == "ubuntu" && "${VERSION_ID:-}" == "24.04" ]] || { echo "Attendu Ubuntu 24.04."; exit 1; }; }

check_locks(){
  log "Vérification locks apt/dpkg"
  local locks=(/var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/lib/apt/lists/lock /var/cache/apt/archives/lock)
  for f in "${locks[@]}"; do
    if fuser "$f" >/dev/null 2>&1; then
      echo "Lock détecté sur $f. Réessayez plus tard." >&2
      exit 1
    fi
  done
}

main(){
  parse_args "$@"; require_root; setup_logging; check_os; check_locks
  cat <<SUM
Résumé:
- Dry-run: $DRY_RUN
- no-clean: $NO_CLEAN
- include-snap: $INCLUDE_SNAP
- include-flatpak: $INCLUDE_FLATPAK
- include-firmware: $INCLUDE_FIRMWARE
- log: $LOG_FILE
SUM
  if ! $ASSUME_YES && ! confirm "Continuer ?"; then exit 0; fi

  run_cmd dpkg --audit
  run_cmd apt-get check
  run_cmd apt-get update
  run_cmd apt-get -y dist-upgrade

  if $INCLUDE_SNAP && command -v snap >/dev/null 2>&1; then run_cmd snap refresh; fi
  if $INCLUDE_FLATPAK && command -v flatpak >/dev/null 2>&1; then run_cmd flatpak update -y; fi
  if $INCLUDE_FIRMWARE && command -v fwupdmgr >/dev/null 2>&1; then run_cmd fwupdmgr refresh --force; run_cmd fwupdmgr update -y; fi

  if ! $NO_CLEAN; then
    log "Autoremove --purge va supprimer les paquets inutiles."
    if confirm "Exécuter apt-get autoremove --purge ?"; then run_cmd apt-get -y autoremove --purge; fi
    log "Autoclean va nettoyer le cache obsolete."
    if confirm "Exécuter apt-get autoclean ?"; then run_cmd apt-get autoclean; fi
  fi

  run_cmd dpkg --audit
  run_cmd apt-get check

  if ! $NO_REBOOT_CHECK; then
    if [[ -e /run/reboot-required ]]; then
      log "Reboot requis: /run/reboot-required présent."
    else
      log "Pas d'indicateur /run/reboot-required."
    fi
  fi

  if $REBOOT_AFTER; then
    if confirm "Redémarrer maintenant ?"; then run_cmd systemctl reboot; fi
  else
    log "Pas de redémarrage automatique par défaut."
  fi
}

main "$@"
