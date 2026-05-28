.PHONY: help check bootstrap build up down logs health version diag diagnostic clean

APP_URL ?= http://127.0.0.1:8000
COMPOSE ?= docker compose
CURL ?= curl -fsS

help:
	@echo "Commandes disponibles :"
	@echo ""
	@echo "  make help        Affiche cette aide"
	@echo "  make check       Vérifie les prérequis locaux"
	@echo "  make bootstrap   Prépare l'environnement Fedora 44"
	@echo "  make build       Construit l'image Docker"
	@echo "  make up          Lance l'application"
	@echo "  make down        Arrête l'application"
	@echo "  make logs        Affiche les logs Docker"
	@echo "  make health      Teste l'endpoint /health"
	@echo "  make version     Teste l'endpoint /version"
	@echo "  make diag        Teste l'endpoint /diag"
	@echo "  make diagnostic  Alias de make diag"
	@echo "  make clean       Nettoyage léger"
	@echo ""
	@echo "Variable utile :"
	@echo "  APP_URL=$(APP_URL)"

check:
	@echo "Vérification des prérequis..."
	@command -v git >/dev/null || { echo "git est manquant"; exit 1; }
	@command -v docker >/dev/null || { echo "docker est manquant"; exit 1; }
	@docker compose version >/dev/null || { echo "docker compose est manquant"; exit 1; }
	@command -v curl >/dev/null || { echo "curl est manquant"; exit 1; }
	@test -f compose.yaml || { echo "compose.yaml est manquant"; exit 1; }
	@test -f scripts/bootstrap_fedora44_vm.sh || { echo "scripts/bootstrap_fedora44_vm.sh est manquant"; exit 1; }
	@echo "OK : prérequis disponibles"

bootstrap:
	./scripts/bootstrap_fedora44_vm.sh

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

clean:
	$(COMPOSE) down
