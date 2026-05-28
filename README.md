# Network and Systems Training

Projet d'apprentissage autour de Linux, réseau, Docker, FastAPI, automatisation et diagnostic défensif.

## Objectif

Permettre à une personne de :

1. cloner le dépôt ;
2. installer les prérequis adaptés à sa distribution ;
3. lancer l'application avec Docker Compose ;
4. tester `/health`, `/version`, `/diag` ;
5. arrêter proprement le projet.

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
git clone <url-du-repo>
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
| `make bootstrap-fedora` | Installe les prérequis sur Fedora 44 VM |
| `make bootstrap-ubuntu` | Installe les prérequis sur Ubuntu 24.04.4 LTS |
| `make check` | Vérifie l'environnement de reproductibilité |
| `make build` | Construit l'image Docker |
| `make up` | Démarre l'application via Docker Compose |
| `make health` | Teste `GET /health` |
| `make version` | Teste `GET /version` |
| `make diag` | Teste `GET /diag` |
| `make down` | Arrête proprement le projet |

## Documentation de reproductibilité

- `docs/reproductibilite-linux-generique.md`
- `docs/reproductibilite-fedora-44-vm.md`
- `docs/reproductibilite-ubuntu-24.04.md`
