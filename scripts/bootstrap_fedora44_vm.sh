#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

log() {
  printf '[%s] %s\n' "$SCRIPT_NAME" "$*"
}

if [[ "${EUID}" -eq 0 ]]; then
  log "Ce script doit être lancé avec un utilisateur standard (pas root)."
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  log "La commande 'sudo' est requise."
  exit 1
fi

if ! command -v dnf >/dev/null 2>&1; then
  log "Ce script est prévu pour Fedora (dnf introuvable)."
  exit 1
fi

if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
  NEED_RELOGIN=1
else
  NEED_RELOGIN=0
fi

log "Mise à jour de Fedora"
sudo dnf -y update

log "Installation des outils de base"
sudo dnf -y install \
  git \
  curl \
  wget \
  vim \
  nano \
  tree \
  jq \
  make \
  python3 \
  python3-pip \
  python3-virtualenv \
  ansible \
  ShellCheck \
  dnf-plugins-core

log "Suppression éventuelle d'anciens paquets Docker conflictuels"
sudo dnf -y remove \
  docker \
  docker-client \
  docker-client-latest \
  docker-common \
  docker-latest \
  docker-latest-logrotate \
  docker-logrotate \
  docker-selinux \
  docker-engine-selinux \
  docker-engine || true

log "Ajout du dépôt Docker officiel"
sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo

log "Installation Docker Engine + Compose plugin"
sudo dnf -y install \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

log "Activation de Docker"
sudo systemctl enable --now docker

log "Ajout de l'utilisateur courant au groupe docker"
sudo usermod -aG docker "$USER"

echo
echo "Installation terminée."
if [[ "$NEED_RELOGIN" -eq 1 ]]; then
  echo "IMPORTANT : déconnecte-toi/reconnecte-toi dans la VM pour appliquer le groupe docker."
else
  echo "L'utilisateur était déjà dans le groupe docker."
fi
echo
echo "Puis vérifie :"
echo "  docker --version"
echo "  docker compose version"
echo "  ansible --version"
