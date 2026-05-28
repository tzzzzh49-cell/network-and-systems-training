# Reproductibilité sur Ubuntu 24.04.4 LTS

## Portée
Ce guide couvre uniquement **Ubuntu 24.04.4 LTS**.

## Prérequis
- VM ou machine Ubuntu 24.04.4 LTS.
- Utilisateur avec droits `sudo`.
- Accès réseau sortant (APT + Docker Hub).

## 1) Cloner le dépôt
```bash
git clone <URL_DU_DEPOT>
cd network-and-systems-training
```

## 2) Installer les dépendances Ubuntu
```bash
make bootstrap-ubuntu
```

## 3) Vérifier l'environnement
```bash
make check
```

## 4) Lancer l'application
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

## 6) Arrêt propre
```bash
make down
```
