#!/usr/bin/env bash
set -euo pipefail

echo "==> Mise à jour de l'index APT"
sudo apt-get update

echo "==> Installation des outils de base"
sudo apt-get install -y \
  ca-certificates \
  curl \
  git \
  jq \
  make \
  python3 \
  python3-pip \
  python3-venv \
  software-properties-common \
  ansible \
  shellcheck

echo "==> Suppression éventuelle d'anciens paquets Docker conflictuels"
sudo apt-get remove -y \
  docker.io \
  docker-doc \
  docker-compose \
  docker-compose-v2 \
  podman-docker \
  containerd \
  runc || true

echo "==> Ajout de la clé GPG Docker officielle"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "==> Ajout du dépôt Docker officiel"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

echo "==> Installation Docker Engine + Compose plugin"
sudo apt-get update
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "==> Activation de Docker"
sudo systemctl enable --now docker

echo "==> Ajout de l'utilisateur courant au groupe docker"
sudo usermod -aG docker "$USER"

echo
echo "Installation terminée."
echo "IMPORTANT : déconnecte-toi/reconnecte-toi dans la VM."
echo
echo "Puis vérifie :"
echo "  docker --version"
echo "  docker compose version"
echo "  ansible --version"
