#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME="$(basename "$0")"
LOG_DIR="/var/log/clean-system-update"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${LOG_DIR}/rhel-update-${TIMESTAMP}.log"
UPDATED_FILE="/tmp/rhel-updated-packages-${TIMESTAMP}.txt"

DRY_RUN=false
ASSUME_YES=false
NO_CLEAN=false
NO_REBOOT_CHECK=false
SECURITY_ONLY=false
ALLOW_COMPATIBLE=false
REBOOT_AFTER=false
CLEAN_MODE="packages" # packages|all

usage(){ cat <<USAGE
Usage: $SCRIPT_NAME [--dry-run] [--yes] [--no-clean] [--security-only] [--allow-compatible] [--reboot] [--clean-all]
USAGE
}
log(){ echo "[$(date +'%F %T')] $*"; }
run_cmd(){ if $DRY_RUN; then log "[DRY-RUN] $*"; else log "[RUN] $*"; "$@"; fi; }
confirm(){ $ASSUME_YES && return 0; read -r -p "$1 [y/N]: " a; [[ "$a" =~ ^[Yy]$ ]]; }

parse_args(){ while [[ $# -gt 0 ]]; do case "$1" in
  --dry-run) DRY_RUN=true;; --yes) ASSUME_YES=true;; --no-clean) NO_CLEAN=true;; --no-reboot-check) NO_REBOOT_CHECK=true;; --security-only) SECURITY_ONLY=true;;
  --allow-compatible) ALLOW_COMPATIBLE=true;; --reboot) REBOOT_AFTER=true;; --clean-all) CLEAN_MODE="all";; -h|--help) usage; exit 0;; *) echo "Option inconnue: $1"; exit 1;; esac; shift; done; }

require_root(){ [[ "$EUID" -eq 0 ]] || { echo "Exécuter en root/sudo."; exit 1; }; }
setup_log(){ mkdir -p "$LOG_DIR"; touch "$LOG_FILE"; exec > >(tee -a "$LOG_FILE") 2>&1; }

check_os(){
  source /etc/os-release
  local ok=false
  if [[ "${ID:-}" == "rhel" ]]; then ok=true; fi
  if $ALLOW_COMPATIBLE && [[ "${ID_LIKE:-}" =~ rhel|fedora ]]; then ok=true; fi
  if ! $ok; then echo "OS non supporté (attendu RHEL)."; exit 1; fi
  if [[ ! "${VERSION_ID:-}" =~ ^(8|9|10)(\.|$) ]]; then echo "Version RHEL supportée: 8/9/10."; exit 1; fi
}

main(){
  parse_args "$@"; require_root; setup_log; check_os
  log "Résumé: dry-run=$DRY_RUN security-only=$SECURITY_ONLY no-clean=$NO_CLEAN clean-mode=$CLEAN_MODE"
  if ! $ASSUME_YES && ! confirm "Continuer ?"; then exit 0; fi

  if command -v subscription-manager >/dev/null 2>&1; then
    run_cmd subscription-manager status || log "subscription-manager status non bloquant en lab/test."
  fi

  run_cmd dnf repolist
  run_cmd dnf history list
  run_cmd dnf check-update

  if $SECURITY_ONLY; then
    run_cmd dnf -y upgrade --security
  else
    run_cmd dnf -y upgrade
  fi

  if ! $DRY_RUN; then dnf history info last | sed -n '/Packages Altered:/,$p' > "$UPDATED_FILE" || true; fi
  run_cmd dnf history list

  if ! $NO_CLEAN; then
    log "Paquets candidats autoremove:"; run_cmd dnf repoquery --unneeded
    if confirm "Exécuter dnf autoremove ?"; then run_cmd dnf -y autoremove; fi
    log "Nettoyage cache DNF: dnf clean $CLEAN_MODE"
    if confirm "Exécuter nettoyage cache ?"; then run_cmd dnf clean "$CLEAN_MODE"; fi
  fi

  if ! $NO_REBOOT_CHECK && [[ -f "$UPDATED_FILE" ]] && grep -Eiq '(^| )(kernel|systemd|glibc)( |$)' "$UPDATED_FILE"; then
    log "Reboot recommandé après MAJ kernel/systemd/glibc."
  fi

  if $REBOOT_AFTER; then
    if confirm "Redémarrer maintenant ?"; then run_cmd systemctl reboot; fi
  else
    log "Pas de redémarrage automatique sans --reboot."
  fi
}

main "$@"
