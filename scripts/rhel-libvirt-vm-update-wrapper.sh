#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME="$(basename "$0")"
DRY_RUN=false
ASSUME_YES=false
ALLOW_NO_SNAPSHOT=false
REMOTE_PATH="/tmp/rhel-clean-update.sh"
VM_LIST_FILE=""
declare -a VMS=()
declare -a RHEL_ARGS=()
SSH_USER="root"

usage(){ cat <<USAGE
Usage: $SCRIPT_NAME [--vm NAME]... [--vm-file FILE] [--copy-to usr-local-sbin|tmp] [--dry-run] [--allow-no-snapshot] [--yes]
USAGE
}
log(){ echo "[$(date +'%F %T')] $*"; }
run_cmd(){ if $DRY_RUN; then log "[DRY-RUN] $*"; else log "[RUN] $*"; "$@"; fi; }
confirm(){ $ASSUME_YES && return 0; read -r -p "$1 [y/N]: " a; [[ "$a" =~ ^[Yy]$ ]]; }

parse_args(){ while [[ $# -gt 0 ]]; do case "$1" in
  --vm) VMS+=("$2"); shift;; --vm-file) VM_LIST_FILE="$2"; shift;; --copy-to) [[ "$2" == "usr-local-sbin" ]] && REMOTE_PATH="/usr/local/sbin/rhel-clean-update.sh" || REMOTE_PATH="/tmp/rhel-clean-update.sh"; shift;;
  --ssh-user) SSH_USER="$2"; shift;; --dry-run) DRY_RUN=true;; --yes) ASSUME_YES=true;; --allow-no-snapshot) ALLOW_NO_SNAPSHOT=true;;
  --security-only|--no-clean|--no-reboot-check|--reboot|--dry-run-rhel) RHEL_ARGS+=("$1");;
  -h|--help) usage; exit 0;; *) echo "Option inconnue: $1"; exit 1;; esac; shift; done; }

load_vm_file(){
  [[ -z "$VM_LIST_FILE" ]] && return
  while IFS= read -r line; do [[ -n "$line" ]] && VMS+=("$line"); done < "$VM_LIST_FILE"
}

main(){
  parse_args "$@"
  load_vm_file
  command -v virsh >/dev/null 2>&1 || { echo "virsh est requis"; exit 1; }
  [[ ${#VMS[@]} -gt 0 ]] || { echo "Aucune VM fournie"; exit 1; }

  log "Résumé: vm_count=${#VMS[@]} dry-run=$DRY_RUN remote_path=$REMOTE_PATH allow-no-snapshot=$ALLOW_NO_SNAPSHOT"
  if ! $ASSUME_YES && ! confirm "Continuer avec la mise à jour des VM ?"; then exit 0; fi

  for vm in "${VMS[@]}"; do
    log "===== VM: $vm ====="
    run_cmd virsh dominfo "$vm" >/dev/null

    local_snap="preupdate-${vm}-$(date +%Y%m%d-%H%M%S)"
    state="$(virsh domstate "$vm" 2>/dev/null || true)"

    if [[ "$state" =~ running ]]; then
      if virsh qemu-agent-command "$vm" '{"execute":"guest-ping"}' >/dev/null 2>&1; then
        if ! run_cmd virsh snapshot-create-as --domain "$vm" --name "$local_snap" --disk-only --atomic --quiesce; then
          $ALLOW_NO_SNAPSHOT || { echo "Snapshot impossible pour $vm (running). Abandon."; continue; }
        fi
      else
        if ! run_cmd virsh snapshot-create-as --domain "$vm" --name "$local_snap" --disk-only --atomic; then
          $ALLOW_NO_SNAPSHOT || { echo "Snapshot impossible pour $vm (running sans qga). Abandon."; continue; }
        fi
      fi
    else
      if ! run_cmd virsh snapshot-create-as --domain "$vm" --name "$local_snap" --disk-only --atomic; then
        $ALLOW_NO_SNAPSHOT || { echo "Snapshot impossible pour $vm (stopped). Abandon."; continue; }
      fi
    fi

    run_cmd scp scripts/rhel-clean-update.sh "${SSH_USER}@${vm}:${REMOTE_PATH}"
    run_cmd ssh "${SSH_USER}@${vm}" "chmod +x ${REMOTE_PATH} && ${REMOTE_PATH} ${RHEL_ARGS[*]}"
    run_cmd scp "${SSH_USER}@${vm}:/var/log/clean-system-update/""rhel-update-*.log" "./${vm}-logs/" || true

    log "Rollback (non exécuté):"
    log "  virsh snapshot-list $vm"
    log "  virsh snapshot-revert $vm $local_snap"
  done
}

main "$@"
