# Network and Systems Training

Projet d'apprentissage Linux/réseau/Docker/FastAPI orienté reproductibilité sur VM.

## Compatibilité Linux

| Distribution | Version cible | Statut |
|---|---|---|
| Fedora Workstation VM | 44 | Validée / à revalider à chaque évolution majeure |
| Ubuntu LTS | 24.04.4 | Validée / à revalider à chaque évolution majeure |

> Le projet **ne prétend pas** fonctionner sur toutes les distributions Linux.

## Prérequis
- `git`
- `curl`
- `make`
- `docker` + `docker compose`
- `python3`
- `ansible`

## Bootstrap par distribution
- Fedora 44 : `make bootstrap-fedora`
- Ubuntu 24.04.4 : `make bootstrap-ubuntu`

Documentation détaillée :
- `docs/reproductibilite-fedora-44-vm.md`
- `docs/reproductibilite-ubuntu-24.04.md`
- `docs/reproductibilite-linux-generique.md`

## Workflow reproductible
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

## Endpoints
- `GET /health`
- `GET /version`
- `GET /diag`
