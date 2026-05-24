#!/usr/bin/env bash
set -euo pipefail

echo "==> Vérification des commandes"

commands=(
  git
  python3
  pip3
  docker
  ansible
  ansible-playbook
  make
  curl
)

for cmd in "${commands[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK   $cmd -> $(command -v "$cmd")"
  else
    echo "ERREUR : commande manquante : $cmd"
    exit 1
  fi
done

echo
echo "==> Versions"
git --version
python3 --version
docker --version
docker compose version
ansible --version | head -n 1

echo
echo "==> Vérification des fichiers importants"

required_paths=(
  "README.md"
  "AGENTS.md"
  "compose.yaml"
  "app/Dockerfile"
  "app/main.py"
  "app/requirements.txt"
  "ansible/inventory.yml"
  "ansible/playbooks/diagnostic.yml"
  "scripts/diagnostic_local.sh"
  ".env.example"
)

for path in "${required_paths[@]}"; do
  if [ -e "$path" ]; then
    echo "OK   $path"
  else
    echo "ERREUR : fichier manquant : $path"
    exit 1
  fi
done

echo
echo "==> Vérification Docker Compose"
docker compose config >/tmp/compose-check.yml
echo "OK   compose.yaml est valide"

echo
echo "==> Build Docker"
docker compose build

echo
echo "==> Test Ansible en mode check"
ansible-playbook -i ansible/inventory.yml ansible/playbooks/diagnostic.yml --check

echo
echo "Reproductibilité OK."
