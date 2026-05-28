# Reproductibilité Linux (générique)

Ce projet n'est pas déclaré compatible avec « toutes » les distributions Linux.

## Cibles supportées dans ce dépôt

- **Fedora 44 Workstation VM** (validée)
- **Ubuntu 24.04.4 LTS** (à valider/valider selon vos tests internes)

## Workflow standard

1. Cloner le dépôt.
2. Installer les prérequis via le script de votre distribution.
3. Vérifier l'environnement (`make check`).
4. Construire (`make build`).
5. Démarrer (`make up`).
6. Tester `/health`, `/version`, `/diag`.
7. Arrêter proprement (`make down`).

## Références

- `docs/reproductibilite-fedora-44-vm.md`
- `docs/reproductibilite-ubuntu-24.04.md`
