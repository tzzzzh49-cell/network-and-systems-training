# voice-controlled-network-lab

Mini lab local pour apprendre Docker, Ansible, les diagnostics Linux et les bases d'une API Python.

## Demarrage rapide sur Fedora 44 Workstation

Dans une VM Fedora 44 neuve :

```bash
cd ~/Documents/labs/voice-controlled-network-lab
./scripts/bootstrap_fedora44_vm.sh
```

Puis teste l'API :

```bash
curl http://127.0.0.1:8000/health
```

Reponse attendue :

```json
{"status":"ok","service":"lab-api"}
```

## Commandes courantes

```bash
make up
```

Lance l'API.

```bash
make logs
```

Affiche les logs.

```bash
make down
```

Arrete l'API.

```bash
make diag
```

Genere un rapport local dans `outputs/reports/`.

## Documentation

Le guide detaille pour une VM QEMU/KVM/libvirt Fedora 44 est ici :

```text
docs/reproductibilite-fedora-44-vm.md
```
