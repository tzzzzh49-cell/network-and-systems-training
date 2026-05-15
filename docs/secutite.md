# Sécurité du projet

## Objectif

Ce document explique les règles de sécurité de mon projet `voice-controlled-network-lab`.

Le but du projet est d’apprendre à piloter un lab DevOps / réseau avec des outils comme Linux, SSH, Git, Docker, Ansible, Codex CLI et OpenClaw.

La règle principale est simple :

> Au début, aucune commande vocale ou mobile ne doit modifier directement le système ou le réseau.

Le projet doit d’abord être capable de faire des diagnostics, produire des rapports, sauvegarder des états et expliquer ce qui se passe.

---

## Principe de départ

Je commence en mode **read-only**.

Cela signifie que les premières actions autorisées sont seulement :

- lire l’état du système ;
- vérifier les services ;
- afficher les interfaces réseau ;
- afficher les routes ;
- tester la disponibilité d’une API ;
- générer un rapport Markdown ;
- sauvegarder une configuration ;
- résumer un rapport.

Les actions de modification viendront plus tard, seulement quand les diagnostics seront fiables.

---

## Ce qui est autorisé au début

Commandes ou actions acceptées :

```
./scripts/diagnostic_local.sh
python scripts/generate_report.py
ansible-playbook ansible/playbooks/diagnostic.yml
docker compose ps
docker compose logs --tail=50
curl http://127.0.0.1:8000/health
ip a
ip route
ss -tulpn
systemctl status
journalctl -n 100
```

## Ce qui est interdit au début 

Commandes ou actions interdites :

```

rm -rf
sudo sans justification
chmod -R
chown -R
docker system prune
terraform apply
kubectl delete
bash arbitraire
sh arbitraire
python -c
modification réseau directe
suppression de fichiers
exposition publique d’un service sensible
```
