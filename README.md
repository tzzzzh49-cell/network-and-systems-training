# Network and Systems Training

Projet d’apprentissage autour de Linux, des réseaux, de Docker, de FastAPI, de l’automatisation et de la cybersécurité défensive.

L’objectif est de construire progressivement un lab capable de :

- exposer une API FastAPI minimale ;
- lancer des diagnostics système et réseau en lecture seule ;
- produire des rapports techniques ;
- être déployé plus tard sur un VPS ;
- intégrer progressivement les API OpenAI et OpenClaw de manière sécurisée.

## Portée de reproductibilité Linux

Ce dépôt **ne prétend pas** fonctionner sur toutes les distributions Linux.

### Matrice de compatibilité Linux

| Distribution | Version cible | Statut |
|---|---:|---|
| Fedora Workstation (VM) | 44 | Validée |
| Ubuntu LTS (VM) | 24.04.4 | À valider |

## Pré-requis

- Git
- Accès Internet
- Un utilisateur avec droits `sudo`
- Docker Engine + Docker Compose plugin
- Make
- Curl
- JQ
- Python 3
- Ansible

## Démarrage rapide

```bash
git clone <url-du-repo>
cd network-and-systems-training

# Choisir selon la distribution
make bootstrap-fedora
# ou
make bootstrap-ubuntu

# Vérifications et exécution
make check
make build
make up
make health
make version
make diag
make down
```

## Commandes disponibles

| Commande | Description |
|---|---|
| `make help` | Affiche les commandes disponibles |
| `make bootstrap-fedora` | Installe les prérequis Fedora 44 VM |
| `make bootstrap-ubuntu` | Installe les prérequis Ubuntu 24.04.4 |
| `make check` | Vérifie les prérequis et la configuration |
| `make build` | Construit l’image Docker |
| `make up` | Lance l’application |
| `make health` | Vérifie `/health` |
| `make version` | Vérifie `/version` |
| `make diag` | Vérifie `/diag` |
| `make logs` | Affiche les logs Docker |
| `make down` | Arrête l’application |

## Guides de reproductibilité

- [Fedora 44 Workstation VM](docs/reproductibilite-fedora-44-vm.md)
- [Ubuntu 24.04.4 LTS](docs/reproductibilite-ubuntu-24.04.md)
- [Linux générique (portée)](docs/reproductibilite-linux-generique.md)

## Sécurité

Le projet démarre volontairement en mode lecture seule.
Aucune commande destructive ne doit être automatisée à ce stade.
