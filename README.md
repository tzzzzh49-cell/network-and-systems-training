# Network and Systems Training

Projet d’apprentissage autour de Linux, des réseaux, de Docker, de FastAPI, de l’automatisation et de la cybersécurité défensive.

## Objectif de reproductibilité

Une personne doit pouvoir :

1. cloner le dépôt ;
2. installer les prérequis adaptés à sa distribution ;
3. lancer l’application avec Docker Compose ;
4. tester `/health`, `/version`, `/diag` ;
5. arrêter proprement l’environnement.

## Matrice de compatibilité Linux

| Distribution | Version | Statut |
|---|---|---|
| Fedora Workstation (VM) | 44 | Cible validée / à valider à chaque évolution majeure |
| Ubuntu LTS | 24.04.4 | Cible validée / à valider à chaque évolution majeure |

> Le projet **ne prétend pas** fonctionner sur toutes les distributions Linux.

## Pré-requis

- Git
- Make
- Docker Engine
- Docker Compose plugin (`docker compose`)
- Curl

## Démarrage rapide

```bash
git clone <url-du-repo>
cd network-and-systems-training

# Choisir un bootstrap selon la distribution
make bootstrap-fedora
# ou
make bootstrap-ubuntu

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
| `make bootstrap-fedora` | Prépare Fedora 44 VM |
| `make bootstrap-ubuntu` | Prépare Ubuntu 24.04.4 LTS |
| `make check` | Vérifie les prérequis et la reproductibilité locale |
| `make build` | Construit l’image Docker |
| `make up` | Lance l’application |
| `make health` | Teste l’endpoint `/health` |
| `make version` | Teste l’endpoint `/version` |
| `make diag` | Teste l’endpoint `/diag` |
| `make down` | Arrête proprement l’application |
| `make logs` | Affiche les logs Docker |

## Documentation de reproduction

- `docs/reproductibilite-linux-generique.md`
- `docs/reproductibilite-fedora-44-vm.md`
- `docs/reproductibilite-ubuntu-24.04.md`
