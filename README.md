# # Network and Systems Training

Projet d’apprentissage autour de Linux, des réseaux, de Docker, de FastAPI, de l’automatisation et de la cybersécurité défensive.

L’objectif est de construire progressivement un lab capable de :

- exposer une API FastAPI minimale ;
- lancer des diagnostics système et réseau en lecture seule ;
- produire des rapports techniques ;
- être déployé plus tard sur un VPS ;
- intégrer progressivement les API OpenAI et OpenClaw de manière sécurisée.

## Statut du projet

Version actuelle : v0.1.0

Le projet est actuellement une base de lab systèmes/réseaux/DevOps/cybersécurité.

Fonctionnalités disponibles :
- API FastAPI minimale ;
- endpoints `/health`, `/version` et `/diag` ;
- lancement avec Docker Compose ;
- commandes Makefile principales ;
- reproduction testée sur VM Fedora 44 ;
- documentation technique initiale ;
- règles de sécurité en lecture seule.

Fonctionnalités prévues :
- tests automatisés avec pytest ;
- lint Python avec ruff ;
- vérification ShellCheck ;
- CI GitHub Actions ;
- diagnostic réseau plus avancé ;
- déploiement VPS ;
- intégration progressive OpenAI API ;
- intégration contrôlée OpenClaw.

## Sécurité

Le projet démarre volontairement en mode lecture seule.  
Aucune commande destructive ne doit être automatisée à ce stade.

## Démarrage rapide

```bash
git clone https://github.com/tzzzzh49-cell/network-and-systems-training.git
cd network-and-systems-training
make check
make build
make up
make health
make version
make diag
make down

## Commandes principales

| Commande | Description |
|---|---|
| `make help` | Affiche les commandes disponibles |
| `make check` | Vérifie les prérequis locaux |
| `make bootstrap` | Prépare l’environnement Fedora 44 |
| `make build` | Construit l’image Docker |
| `make up` | Lance l’application |
| `make health` | Vérifie l’endpoint `/health` |
| `make version` | Vérifie l’endpoint `/version` |
| `make diag` | Vérifie l’endpoint `/diag` |
| `make logs` | Affiche les logs Docker |
| `make down` | Arrête l’application |
| `make clean` | Effectue un nettoyage léger |

## Documentation

- [Architecture](docs/architecture.md)
- [Sécurité](docs/securite.md)
- [Reproductibilité Fedora 44](docs/reproductibilite-fedora-44-vm.md)
- [Journal d’apprentissage](docs/journal-apprentissage.md)
- [ADR-001 — Mode lecture seule](docs/decisions/ADR-001-mode-read-only.md)

Le projet est documenté progressivement afin de montrer les choix techniques, les règles de sécurité et les apprentissages réalisés.
