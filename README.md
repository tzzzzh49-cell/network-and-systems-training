# Clean System Update Scripts (Fedora 44 / Ubuntu 24.04 / RHEL 8-10)

## But du projet
Ce projet fournit des scripts Bash prudents pour réaliser des **mises à jour de paquets** (et non des upgrades majeurs de distribution) sur Fedora, Ubuntu et RHEL, avec journalisation, confirmations, mode simulation et nettoyage contrôlé.

## Mise à jour de paquets vs mise à niveau de version
- **Mise à jour de paquets**: installe des versions plus récentes de paquets dans la même version de l'OS.
- **Mise à niveau de version**: change la version majeure de l'OS (ex. Fedora 44 -> 45, Ubuntu 24.04 -> 26.04). Ce projet **ne fait pas** cela.

## Exemples d'utilisation
```bash
sudo ./scripts/fedora44-clean-update.sh --dry-run
sudo ./scripts/fedora44-clean-update.sh --include-flatpak --include-firmware
sudo ./scripts/ubuntu2404-clean-update.sh --dry-run
sudo ./scripts/ubuntu2404-clean-update.sh --include-snap --include-flatpak
sudo ./scripts/rhel-clean-update.sh --security-only
sudo ./scripts/rhel-libvirt-vm-update-wrapper.sh --vm rhel-test-01 --dry-run
```

## Ce que le script ne fait pas
- Ne lance pas de `do-release-upgrade`.
- Ne fait pas de `dnf distro-sync` par défaut.
- Ne supprime pas automatiquement des paquets sans confirmation explicite (ou `--yes`).
- Ne redémarre pas automatiquement sans option `--reboot`.
- Ne supprime jamais les snapshots VM automatiquement.

## Risques et précautions
- Toujours exécuter d'abord en `--dry-run`.
- Vérifier l'espace disque et la santé réseau.
- Prévoir un backup/snapshot avant maintenance.
- Lire `docs/SAFETY.md` avant usage en production.

## Fichiers
- `scripts/fedora44-clean-update.sh`
- `scripts/ubuntu2404-clean-update.sh`
- `scripts/rhel-clean-update.sh`
- `scripts/rhel-libvirt-vm-update-wrapper.sh`
- `docs/USAGE.md`
- `docs/SAFETY.md`
