.PHONY: help bootstrap-fedora bootstrap-ubuntu check build up health version diag down logs ansible-check diagnostic clean

help:
	@echo "Commandes disponibles:"
	@echo "  make bootstrap-fedora"
	@echo "  make bootstrap-ubuntu"
	@echo "  make check"
	@echo "  make build"
	@echo "  make up"
	@echo "  make health"
	@echo "  make version"
	@echo "  make diag"
	@echo "  make down"
	@echo "  make logs"

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

ansible-check:
	ansible-playbook -i ansible/inventory.yml ansible/playbooks/diagnostic.yml --check

diagnostic:
	./scripts/diagnostic_local.sh

clean:
	docker compose down --remove-orphans
