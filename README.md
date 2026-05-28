# Network and Systems Training

Projet d'apprentissage autour de Linux, réseau, Docker, FastAPI, automatisation et diagnostic défensif.

## Objectif

Permettre à une personne de :

1. cloner le dépôt ;
2. installer les prérequis adaptés à sa distribution ;
3. lancer l'application avec Docker Compose ;
4. tester `/health`, `/version`, `/diag` ;
5. arrêter proprement le projet.

## Statut du projet

Version actuelle : v0.1.0

Le projet est actuellement une base de lab systèmes/réseaux/DevOps/cybersécurité.

Fonctionnalités disponibles :
- API FastAPI minimale ;
- endpoints `/health`, `/version` et `/diag` ;
- lancement avec Docker Compose ;
- commandes Makefile principales ;
- reproduction testée sur VM Fedora 44 ;
- documentation de reproductibilité Fedora et Ubuntu ;
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

## Matrice de compatibilité Linux

| Distribution | Version | Statut |
|---|---|---|
| Fedora Workstation VM | 44 | Cible validée/à valider |
| Ubuntu LTS | 24.04.4 | Cible validée/à valider |

> Le projet **ne prétend pas** fonctionner sur toutes les distributions Linux à ce stade.

## Pré-requis

- Git
- Docker Engine
- Docker Compose plugin (`docker compose`)
- Make
- Curl
- Python 3
- Ansible

Les prérequis sont installés automatiquement via les scripts de bootstrap ci-dessous.

## Bootstrap par distribution

### Fedora 44 Workstation VM

```bash
make bootstrap-fedora
```

Documentation détaillée : `docs/reproductibilite-fedora-44-vm.md`.

### Ubuntu 24.04.4 LTS

```bash
make bootstrap-ubuntu
```

Documentation détaillée : `docs/reproductibilite-ubuntu-24.04.md`.

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
```

## Commandes Makefile

| Commande | Description |
|---|---|
| `make help` | Affiche les commandes disponibles |
| `make check` | Vérifie l'environnement de reproductibilité |
| `make bootstrap` | Alias de `make bootstrap-fedora` |
| `make bootstrap-fedora` | Installe les prérequis sur Fedora 44 VM |
| `make bootstrap-ubuntu` | Installe les prérequis sur Ubuntu 24.04.4 LTS |
| `make build` | Construit l'image Docker |
| `make up` | Démarre l'application via Docker Compose |
| `make health` | Teste `GET /health` |
| `make version` | Teste `GET /version` |
| `make diag` | Teste `GET /diag` |
| `make logs` | Affiche les logs Docker |
| `make down` | Arrête proprement le projet |
| `make clean` | Effectue un nettoyage léger |

## Documentation

- [Architecture](docs/architecture.md)
- [Sécurité](docs/securite.md)
- [Reproductibilité Linux générique](docs/reproductibilite-linux-generique.md)
- [Reproductibilité Fedora 44](docs/reproductibilite-fedora-44-vm.md)
- [Reproductibilité Ubuntu 24.04](docs/reproductibilite-ubuntu-24.04.md)
- [Journal d'apprentissage](docs/journal-apprentissage.md)
- [ADR-001 - Mode lecture seule](docs/decisions/ADR-001-mode-read-only.md)

Le projet est documenté progressivement afin de montrer les choix techniques, les règles de sécurité et les apprentissages réalisés.
