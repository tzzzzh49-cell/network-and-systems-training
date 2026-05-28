.PHONY: help bootstrap bootstrap-fedora bootstrap-ubuntu check build up health version diag down logs test ansible-check diagnostic clean

help:
	@echo "Commandes disponibles :"
	@echo "  make bootstrap-fedora   # Bootstrap Fedora 44 Workstation VM"
	@echo "  make bootstrap-ubuntu   # Bootstrap Ubuntu 24.04.4 LTS"
	@echo "  make check              # Vérifications de reproductibilité"
	@echo "  make build              # Build de l'image Docker"
	@echo "  make up                 # Démarrage du stack"
	@echo "  make health             # Test endpoint /health"
	@echo "  make version            # Test endpoint /version"
	@echo "  make diag               # Test endpoint /diag"
	@echo "  make down               # Arrêt propre du stack"
	@echo "  make logs               # Logs Docker Compose"

bootstrap: bootstrap-fedora

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
	curl -fsS http://127.0.0.1:8000/health

version:
	curl -fsS http://127.0.0.1:8000/version

diag:
	curl -fsS http://127.0.0.1:8000/diag

down:
	docker compose down

logs:
	docker compose logs -f

test: health

ansible-check:
	ansible-playbook -i ansible/inventory.yml ansible/playbooks/diagnostic.yml --check

diagnostic:
	./scripts/diagnostic_local.sh

clean:
	docker compose down --remove-orphans
