#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$PROJECT_ROOT/compose.yaml"

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

missing=0
for cmd in "${commands[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK   $cmd -> $(command -v "$cmd")"
  else
    echo "ERREUR : commande manquante : $cmd"
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

echo
echo "==> Versions"
git --version
python3 --version
pip3 --version
docker --version
docker compose version
ansible --version | head -n 1

echo
echo "==> Vérification des fichiers importants"

required_paths=(
  "$PROJECT_ROOT/README.md"
  "$PROJECT_ROOT/AGENTS.md"
  "$COMPOSE_FILE"
  "$PROJECT_ROOT/app/Dockerfile"
  "$PROJECT_ROOT/app/main.py"
  "$PROJECT_ROOT/app/requirements.txt"
  "$PROJECT_ROOT/ansible/inventory.yml"
  "$PROJECT_ROOT/ansible/playbooks/diagnostic.yml"
  "$PROJECT_ROOT/scripts/diagnostic_local.sh"
  "$PROJECT_ROOT/.env.example"
)

for path in "${required_paths[@]}"; do
  if [[ -e "$path" ]]; then
    echo "OK   ${path#$PROJECT_ROOT/}"
  else
    echo "ERREUR : fichier manquant : ${path#$PROJECT_ROOT/}"
    exit 1
  fi
done

echo
echo "==> Vérification Docker Compose"
docker compose -f "$COMPOSE_FILE" config >/tmp/compose-check.yml
echo "OK   compose.yaml est valide"

echo
echo "==> Build Docker"
docker compose -f "$COMPOSE_FILE" build

echo
echo "==> Test Ansible en mode check"
ansible-playbook -i "$PROJECT_ROOT/ansible/inventory.yml" "$PROJECT_ROOT/ansible/playbooks/diagnostic.yml" --check

echo
echo "Reproductibilité OK."
