# Reproductibilité Linux (périmètre explicite)

Ce document clarifie le périmètre de support.

## Distributions ciblées

- Fedora 44 Workstation VM
- Ubuntu 24.04.4 LTS

Aucune autre distribution Linux n'est déclarée compatible à ce stade.

## Workflow reproductible commun

1. Cloner le dépôt.
2. Exécuter le bootstrap adapté à la distribution.
3. Vérifier l'environnement (`make check`).
4. Construire et lancer (`make build` puis `make up`).
5. Tester les endpoints (`make health`, `make version`, `make diag`).
6. Arrêter proprement (`make down`).

## Bootstrap selon distribution

- Fedora 44 Workstation VM : `make bootstrap-fedora`
- Ubuntu 24.04.4 LTS : `make bootstrap-ubuntu`

## Endpoints attendus

- `GET /health`
- `GET /version`
- `GET /diag`
