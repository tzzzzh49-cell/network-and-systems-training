# Reproductibilité — Ubuntu 24.04.4 LTS

## Cible

- Distribution : Ubuntu 24.04.4 LTS
- Statut : cible validée / à revérifier à chaque changement majeur du dépôt

## Bootstrap Ubuntu

```bash
make bootstrap-ubuntu
```

Commande équivalente :

```bash
./scripts/bootstrap_ubuntu2404.sh
```

Le script installe les dépendances nécessaires (Git, Make, Python, Ansible, Docker Engine, Docker Compose plugin) et active le service Docker.

> Important : après l’ajout au groupe `docker`, déconnecte-toi/reconnecte-toi à la session.

## Vérification de la chaîne locale

```bash
make check
```

## Build, run, tests d’API, arrêt

```bash
make build
make up
make health
make version
make diag
make down
```

## Résultat attendu

- `/health` répond en succès HTTP ;
- `/version` renvoie les métadonnées de version ;
- `/diag` renvoie les informations de diagnostic attendues.
