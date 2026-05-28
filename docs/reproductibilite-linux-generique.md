# Reproductibilité Linux (générique)

Ce document décrit le flux standard de reproduction pour ce dépôt.

## Plateformes cibles

Ce flux est **ciblé** sur :

- Fedora 44 Workstation VM ;
- Ubuntu 24.04.4 LTS.

Aucune autre distribution Linux n’est déclarée compatible à ce stade.

## Pré-requis minimaux

- Git ;
- Docker Engine ;
- Docker Compose plugin (`docker compose`) ;
- Make ;
- Curl.

## Cycle de reproduction

```bash
git clone <url-du-repo>
cd network-and-systems-training

# Préparer l’environnement (choisir la bonne distro)
make bootstrap-fedora
# ou
make bootstrap-ubuntu

# Vérifications locales
make check

# Build et démarrage
make build
make up

# Tests endpoints
make health
make version
make diag

# Arrêt propre
make down
```

## Endpoints testés

- `GET /health`
- `GET /version`
- `GET /diag`

## Règles de sécurité opérationnelle

- Éviter les commandes destructrices ;
- Privilégier les diagnostics en lecture seule ;
- Arrêter systématiquement les services via `make down`.
