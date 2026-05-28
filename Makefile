.PHONY: help bootstrap-fedora bootstrap-ubuntu check build up down logs health version diag ansible-check diagnostic clean

help:
	@echo "Commandes disponibles :"
	@echo "  make bootstrap-fedora  - Installe les prérequis Fedora 44 VM"
	@echo "  make bootstrap-ubuntu  - Installe les prérequis Ubuntu 24.04.4"
	@echo "  make check             - Vérifie les prérequis et la config"
	@echo "  make build             - Construit l'image Docker"
	@echo "  make up                - Lance l'application"
	@echo "  make health            - Teste /health"
	@echo "  make version           - Teste /version"
	@echo "  make diag              - Teste /diag"
	@echo "  make logs              - Affiche les logs"
	@echo "  make down              - Arrête l'application"

bootstrap-fedora:
	./scripts/bootstrap_fedora44_vm.sh

bootstrap-ubuntu:
	./scripts/bootstrap_ubuntu2404.sh

check:
	./scripts/check_reproducibility.sh

build:
	docker compose build

up:
	docker compose up --build -d

health:
	curl -fsS http://127.0.0.1:8000/health | jq .

version:
	curl -fsS http://127.0.0.1:8000/version | jq .

diag:
	curl -fsS http://127.0.0.1:8000/diag | jq .

down:
	docker compose down

logs:
	docker compose logs -f

ansible-check:
	ansible-playbook -i ansible/inventory.yml ansible/playbooks/diagnostic.yml --check

diagnostic:
	./scripts/diagnostic_local.sh

clean:
	docker compose down --remove-orphans
