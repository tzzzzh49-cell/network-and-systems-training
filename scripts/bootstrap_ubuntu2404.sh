#!/usr/bin/env bash
set -euo pipefail

echo "==> Mise à jour de l'index APT"
sudo apt-get update

echo "==> Installation des prérequis système"
sudo apt-get install -y \
  ca-certificates \
  curl \
  git \
  jq \
  make \
  python3 \
  python3-pip \
  python3-venv \
  ansible

echo "==> Installation de Docker Engine + Compose plugin (paquets Ubuntu)"
sudo apt-get install -y \
  docker.io \
  docker-buildx \
  docker-compose-v2

echo "==> Activation de Docker"
sudo systemctl enable --now docker

echo "==> Ajout de l'utilisateur courant au groupe docker"
sudo usermod -aG docker "$USER"

echo
echo "Installation terminée."
echo "IMPORTANT : déconnecte-toi/reconnecte-toi (ou reboot) pour appliquer le groupe docker."
echo
echo "Puis vérifie :"
echo "  docker --version"
echo "  docker compose version"
echo "  ansible --version"
