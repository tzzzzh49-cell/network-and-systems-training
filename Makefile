.PHONY: help check bootstrap bootstrap-fedora bootstrap-ubuntu build up down logs health version diag diagnostic test clean

APP_URL ?= http://127.0.0.1:8000
COMPOSE ?= ./scripts/compose.sh
CURL ?= curl -fsS

help:
	@echo "Commandes disponibles :"
	@echo ""
	@echo "  make help              Affiche cette aide"
	@echo "  make check             Vérifie l'environnement de reproductibilité"
	@echo "  make bootstrap         Alias de make bootstrap-fedora"
	@echo "  make bootstrap-fedora  Prépare l'environnement Fedora 44"
	@echo "  make bootstrap-ubuntu  Prépare l'environnement Ubuntu 24.04.4 LTS"
	@echo "  make build             Construit l'image Docker"
	@echo "  make up                Lance l'application"
	@echo "  make down              Arrête l'application"
	@echo "  make logs              Affiche les logs Docker"
	@echo "  make health            Teste l'endpoint /health"
	@echo "  make version           Teste l'endpoint /version"
	@echo "  make diag              Teste l'endpoint /diag"
	@echo "  make diagnostic        Alias de make diag"
	@echo "  make test              Alias de make health"
	@echo "  make clean             Nettoyage léger"
	@echo ""
	@echo "Variable utile :"
	@echo "  APP_URL=$(APP_URL)"

bootstrap: bootstrap-fedora

bootstrap-fedora:
	./scripts/bootstrap_fedora44_vm.sh

bootstrap-ubuntu:
	./scripts/bootstrap_ubuntu2404.sh

check:
	./scripts/check_reproducibility.sh

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f

health:
	$(CURL) $(APP_URL)/health
	@echo ""

version:
	$(CURL) $(APP_URL)/version
	@echo ""

diag:
	$(CURL) $(APP_URL)/diag
	@echo ""

diagnostic: diag

test: health

clean:
	$(COMPOSE) down
