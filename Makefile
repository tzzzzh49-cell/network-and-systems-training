.PHONY: bootstrap-fedora bootstrap-ubuntu check build up health version diag down logs

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
