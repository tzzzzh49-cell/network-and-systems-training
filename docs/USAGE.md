# Guide d'utilisation

## Pré-requis
- Bash récent
- Exécution en root (sudo)
- Outils paquets natifs (`dnf`/`dnf5`, `apt-get`, `dnf`)
- Pour wrapper VM: `virsh`, `ssh`, `scp`

## Options communes
- `--dry-run` : affiche les commandes sans les exécuter
- `--yes` : accepte les confirmations
- `--no-clean` : ignore autoremove/autoclean/clean
- `--no-reboot-check` : ignore la vérification reboot
- `--reboot` : autorise redémarrage explicite en fin

## Options spécifiques
- `--security-only` : RHEL uniquement
- `--include-flatpak` : Fedora/Ubuntu si flatpak installé
- `--include-snap` : Ubuntu si snap installé
- `--include-firmware` : Fedora/Ubuntu si fwupdmgr installé

## Wrapper libvirt
Exemple:
```bash
sudo ./scripts/rhel-libvirt-vm-update-wrapper.sh --vm rhel-test-01 --security-only
```

Exemple avec fichier de VM:
```bash
sudo ./scripts/rhel-libvirt-vm-update-wrapper.sh --vm-file vm-list.txt --yes
```
