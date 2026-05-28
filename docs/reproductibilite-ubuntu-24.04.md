# Reproductibilité — Ubuntu 24.04.4 LTS

Ce guide décrit un chemin reproductible pour lancer ce projet sur **Ubuntu 24.04.4 LTS**.

## Pré-requis à valider

- VM Ubuntu 24.04.4 LTS
- Utilisateur avec droits `sudo`
- Accès Internet
- `git`

## 1) Cloner le dépôt

```bash
git clone <URL_DU_DEPOT>
cd network-and-systems-training
```

## 2) Installer les dépendances Ubuntu

Un script dédié Ubuntu est fourni :

```bash
make bootstrap-ubuntu
```

Ce script installe notamment Docker Engine, Docker Compose plugin, Python, Ansible et outils CLI.

> Après exécution, déconnecte-toi/reconnecte-toi pour appliquer l'ajout au groupe `docker`.

## 3) Vérifier l'environnement

```bash
make check
```

## 4) Construire et lancer l'application

```bash
make build
make up
```

## 5) Tester les endpoints

```bash
make health
make version
make diag
```

## 6) Arrêter proprement

```bash
make down
```

## Notes de sécurité

- Les scripts fournis évitent les commandes destructrices (pas de purge globale, pas de suppression de volumes).
- Les suppressions éventuelles concernent uniquement d'anciens paquets Docker conflictuels.
