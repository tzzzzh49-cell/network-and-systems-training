# Reproductibilité Linux (générique)

## Objectif
Fournir un flux unique de lancement/retrait du lab sans supposer la compatibilité universelle Linux.

## Distributions ciblées
- Fedora 44 Workstation VM
- Ubuntu 24.04.4 LTS

Aucune autre distribution n'est déclarée compatible à ce stade.

## Cycle standard
```bash
make check
make build
make up
make health
make version
make diag
make down
```

## Notes sécurité
- Les scripts de bootstrap installent des dépendances et activent Docker.
- Ne pas exécuter de commandes destructrices hors du périmètre de ce projet.
