# Runbook OpenClaw — diagnostic lab

## Commande utilisateur

diagnostic lab

## Objectif

Lancer un diagnostic local en lecture seule sur le lab.

Cette commande doit produire un rapport Markdown dans :

outputs/reports/

## Action autorisée

Commande locale autorisée :

./scripts/diagnostic_local.sh

## Réponse attendue

OpenClaw devra répondre avec :

- un résumé court ;
- le chemin du rapport généré ;
- les erreurs éventuelles si le diagnostic échoue.

Exemple de réponse attendue :

Diagnostic terminé.
Rapport généré : outputs/reports/diagnostic-YYYY-MM-DD-HHMM.md

## Règles de sécurité

Cette commande est read-only.

Elle a le droit de lire :

- date
- hostname
- ip a
- ip route
- ss -tulpn
- docker ps
- curl http://127.0.0.1:8000/health

Elle n’a pas le droit de modifier :

- les interfaces réseau ;
- les routes ;
- les conteneurs ;
- les fichiers système ;
- les règles firewall ;
- les ressources cloud ;
- les ressources Kubernetes.

## Interdits explicites

Interdit :

- rm
- rm -rf
- sudo général
- bash arbitraire
- sh arbitraire
- modification réseau directe
- ip link set
- ip route add
- ip route del
- docker stop
- docker rm
- terraform apply
- terraform destroy
- kubectl delete
- kubectl apply
- ansible-playbook de modification

## Critère de réussite

La commande est réussie si :

1. le script scripts/diagnostic_local.sh est lancé ;
2. un rapport est créé dans outputs/reports/ ;
3. aucune modification système ou réseau n’est effectuée ;
4. le chemin du rapport est affiché à l’utilisateur.
