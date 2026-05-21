# Journal d’apprentissage

## Objectif du journal

Ce journal sert à suivre ma progression dans le projet `voice-controlled-network-lab`.

Le but n’est pas seulement de noter des commandes. Le but est de prouver que je comprends ce que je fais, étape par étape.

Je veux utiliser ce journal pour garder une trace claire de :

- ce que j’ai appris ;
- ce que j’ai testé ;
- les erreurs rencontrées ;
- les solutions trouvées ;
- les commandes importantes ;
- les fichiers créés ;
- les prochaines étapes.

Ce document doit m’aider à construire un vrai portfolio technique, pas seulement un dossier rempli de fichiers.

---

## Objectif global du projet

Le projet consiste à construire progressivement un lab DevOps et Network Automation.

L’idée finale est de pouvoir déclencher des actions simples et contrôlées, comme un diagnostic, depuis un smartphone ou une interface ChatOps.

Exemple d’objectif final :

Depuis mon téléphone, je demande :

“Diagnostic lab”

Puis le système lance une action autorisée, produit un rapport Markdown et me répond avec un résumé clair.

Au début, tout doit rester simple et sécurisé. Les premières actions doivent seulement lire l’état du système, vérifier les services, générer des rapports et m’aider à comprendre.

---

## Ma méthode de travail

Ma méthode est la suivante :

Comprendre → tester → documenter → automatiser → vérifier → améliorer

Avant d’automatiser une commande, je dois d’abord être capable de l’exécuter manuellement.

Avant de demander à Codex ou OpenClaw de faire une action, je dois comprendre ce que cette action fait.

Avant de modifier quelque chose, je dois avoir une façon de vérifier si le résultat est correct.

---

## Règles personnelles

Je respecte ces règles pendant tout le projet :

- je n’avance pas trop vite ;
- je documente ce que je comprends ;
- je note les erreurs au lieu de les cacher ;
- je privilégie les petites étapes vérifiables ;
- je ne copie pas une commande sans chercher à la comprendre ;
- je garde une trace des commandes importantes ;
- je fais des commits Git propres ;
- je préfère un projet simple mais clair à un projet compliqué que je ne maîtrise pas.

---

## Compétences que je veux développer

Avec ce projet, je veux progresser sur :

- Linux ;
- SSH ;
- Git ;
- Bash ;
- Python ;
- Docker ;
- Docker Compose ;
- Ansible ;
- API HTTP ;
- diagnostic système ;
- diagnostic réseau ;
- automatisation ;
- sécurité ;
- documentation technique ;
- utilisation encadrée de Codex ;
- préparation à OpenClaw ;
- logique DevOps ;
- bases du Network Automation.

---

## Semaine 1 — Création du projet

### Objectif

Mettre en place la base du dépôt et commencer la documentation.

### Tâches prévues

- créer le dossier du projet ;
- initialiser Git ;
- créer le fichier README.md ;
- créer le fichier AGENTS.md ;
- créer le dossier docs ;
- créer le fichier docs/securite.md ;
- créer le fichier docs/journal-apprentissage.md ;
- créer le fichier docs/linux-ssh.md ;
- faire un premier commit propre.

### Ce que je veux comprendre

À la fin de cette semaine, je veux comprendre :

- pourquoi un dépôt Git est important ;
- pourquoi il faut documenter dès le début ;
- à quoi sert un README ;
- à quoi sert un fichier AGENTS.md ;
- pourquoi la sécurité doit être pensée avant l’automatisation.

### Notes personnelles

Date :

Temps passé :

Ce que j’ai fait :

Ce que j’ai compris :

Ce qui reste flou :

Prochaine action :

---

## Semaine 2 — Premiers diagnostics locaux

### Objectif

Créer un premier diagnostic local simple.

Le but est d’apprendre à observer l’état d’une machine Linux avant de chercher à l’automatiser.

### Tâches prévues

- étudier les commandes Linux de diagnostic ;
- observer le système ;
- observer le réseau ;
- observer les ports ouverts ;
- créer un premier script de diagnostic ;
- produire un rapport Markdown dans le dossier outputs/reports.

### Commandes à étudier

hostnamectl

uname -a

ip a

ip route

ss -tulpn

df -h

free -h

systemctl --failed

journalctl -n 100

### Ce que je veux comprendre

À la fin de cette étape, je veux être capable d’expliquer :

- ce qu’est une interface réseau ;
- ce qu’est une route ;
- ce qu’est un port ouvert ;
- ce qu’est un service Linux ;
- ce qu’est un rapport de diagnostic ;
- pourquoi il est important d’avoir une baseline.

### Notes personnelles

Date :

Temps passé :

Ce que j’ai testé :

Résultat obtenu :

Erreur rencontrée :

Solution trouvée :

Prochaine action :

---

## Semaine 3 — Mini API locale

### Objectif

Créer une petite API locale pour avoir une application simple à diagnostiquer et à conteneuriser.

Cette API servira de support pour apprendre Docker, les tests, les rapports et plus tard l’automatisation.

### Endpoints prévus

GET /health

GET /version

GET /diag

### Ce que je veux comprendre

À la fin de cette étape, je veux comprendre :

- ce qu’est une API ;
- ce qu’est un endpoint ;
- ce qu’est un service local ;
- ce que signifie lancer une application avec uvicorn ;
- comment tester une API avec curl ;
- pourquoi un endpoint /health est utile.

### Notes personnelles

Date :

Temps passé :

Fichiers créés :

Commandes utilisées :

Ce qui fonctionne :

Ce qui ne fonctionne pas encore :

Prochaine action :

---

## Semaine 4 — Docker et Docker Compose

### Objectif

Mettre la mini API dans un conteneur Docker.

Le but est de comprendre comment une application peut être emballée avec ses dépendances pour être lancée de manière plus reproductible.

### Fichiers prévus

app/Dockerfile

compose.yaml

### Commandes à étudier

docker compose config

docker compose up --build -d

docker compose ps

docker compose logs --tail=50

docker compose down

### Ce que je veux comprendre

À la fin de cette étape, je veux expliquer simplement :

- ce qu’est une image Docker ;
- ce qu’est un conteneur ;
- ce qu’est un Dockerfile ;
- ce que fait Docker Compose ;
- comment voir les logs d’un conteneur ;
- comment vérifier qu’une API répond depuis un conteneur.

### Notes personnelles

Date :

Temps passé :

Ce que j’ai construit :

Erreur rencontrée :

Solution :

Prochaine amélioration :

---

## Semaine 5 — Ansible local

### Objectif

Découvrir Ansible en local avant de l’utiliser sur des machines distantes ou des équipements réseau.

Le but est de comprendre la logique d’un inventaire, d’un playbook et d’une exécution répétable.

### Fichiers prévus

ansible/inventory.yml

ansible/playbooks/diagnostic.yml

### Commandes à étudier

ansible localhost -i ansible/inventory.yml -m ping

ansible-playbook -i ansible/inventory.yml ansible/playbooks/diagnostic.yml

ansible-playbook -i ansible/inventory.yml ansible/playbooks/diagnostic.yml --check

### Ce que je veux comprendre

À la fin de cette étape, je veux comprendre :

- ce qu’est un inventaire Ansible ;
- ce qu’est un playbook ;
- ce qu’est une tâche ;
- ce qu’est un module ;
- ce que signifie idempotence ;
- à quoi sert le mode --check ;
- la différence entre un script Bash et un playbook Ansible.

### Notes personnelles

Date :

Temps passé :

Commande testée :

Résultat :

Ce que j’ai compris :

Ce qui reste à revoir :

---

## Semaine 6 — Runbooks et préparation OpenClaw

### Objectif

Préparer les futures commandes ChatOps sans encore donner trop de pouvoir à l’automatisation.

Un runbook doit transformer une phrase simple en procédure claire.

Exemple :

Commande utilisateur :

diagnostic lab

Action réelle :

lancer un script de diagnostic ou un playbook de validation

Réponse attendue :

un résumé court et le chemin du rapport généré

### Fichiers prévus

openclaw/runbooks/diagnostic-lab.md

openclaw/allowlists/read-only.md

### Ce que je veux comprendre

À la fin de cette étape, je veux comprendre :

- ce qu’est un runbook ;
- ce qu’est une allowlist ;
- pourquoi il faut refuser par défaut ;
- pourquoi la voix ne doit pas modifier directement le réseau ;
- pourquoi il faut séparer lecture, préparation et exécution.

### Notes personnelles

Date :

Temps passé :

Runbook créé :

Commande autorisée :

Commande interdite :

Ce que j’ai compris :

---

## Fiche quotidienne

### Date

À compléter.

### Temps passé

À compléter.

### Sujet travaillé

À compléter.

### Ce que j’ai fait

- 
- 
- 

### Ce que j’ai compris

- 
- 
- 

### Ce que je n’ai pas encore compris

- 
- 
- 

### Erreur ou blocage rencontré

À compléter.

### Hypothèse

Je pense que le problème vient de :

À compléter.

### Solution testée

À compléter.

### Résultat

À compléter.

### Prochaine action

À compléter.

---

## Bilan hebdomadaire

### Semaine concernée

À compléter.

### Ce que j’ai appris

- 
- 
- 

### Ce que je sais mieux expliquer maintenant

- 
- 
- 

### Les commandes importantes de la semaine

À compléter.

### Les fichiers créés ou modifiés

- 
- 
- 

### Les erreurs rencontrées

- 
- 
- 

### Les solutions trouvées

- 
- 
- 

### Ce qui reste flou

- 
- 
- 

### Objectif de la semaine suivante

À compléter.

---

## Suivi des commits Git importants

### Commit 1

Date :

Message du commit :

Ce que ce commit ajoute :

Pourquoi il est important :

---

### Commit 2

Date :

Message du commit :

Ce que ce commit ajoute :

Pourquoi il est important :

---

## Suivi des notions apprises

### Linux

Notions comprises :

Notions à revoir :

### SSH

Notions comprises :

Notions à revoir :

### Git

Notions comprises :

Notions à revoir :

### Bash

Notions comprises :

Notions à revoir :

### Python

Notions comprises :

Notions à revoir :

### Docker

Notions comprises :

Notions à revoir :

### Ansible

Notions comprises :

Notions à revoir :

### OpenClaw

Notions comprises :

Notions à revoir :

### Codex CLI

Notions comprises :

Notions à revoir :

---

## Objectif portfolio

Chaque semaine, je dois essayer de produire au moins une preuve concrète :

- un fichier Markdown ;
- un script ;
- un rapport ;
- une configuration ;
- un commit Git ;
- une explication claire ;
- une erreur corrigée ;
- une commande comprise.

Le but final est que mon dépôt montre ma progression.

Une personne extérieure doit pouvoir lire le projet et comprendre :

- ce que je construis ;
- pourquoi je le construis ;
- comment je le sécurise ;
- ce que j’ai appris ;
- comment je progresse vers le DevOps et le Network Automation.

## Étape 3 — Mini API locale

J’ai créé une mini API Python avec FastAPI.

Elle contient trois routes principales :

- /health : vérifie que le service fonctionne ;
- /version : affiche la version de l’application ;
- /diag : affiche des informations simples sur la machine et Python.

J’ai lancé l’API avec Uvicorn et je l’ai testée avec curl.

Ce que j’ai compris :

Une API est un service qui répond à des requêtes HTTP.

Uvicorn sert à lancer l’application FastAPI.

L’endpoint /health est utile pour les diagnostics, Docker, les scripts de vérification et plus tard l’automatisation.

## Étape 4 — Script de diagnostic local

J’ai créé un script Bash nommé `scripts/diagnostic_local.sh`.

Son rôle est de produire un rapport Markdown dans `outputs/reports/`.

Le script collecte plusieurs informations :

- date du diagnostic ;
- nom de la machine ;
- version du système ;
- interfaces réseau ;
- routes réseau ;
- ports ouverts ;
- espace disque ;
- mémoire ;
- conteneurs Docker ;
- test de l’endpoint `/health`.

Ce que j’ai compris :

Un script de diagnostic sert à créer une photographie de l’état du système à un moment donné.

Ce rapport pourra servir de preuve avant ou après un changement.

Ce script ne modifie rien sur la machine. Il observe seulement.

## Blocage Docker sur Fedora

L’API fonctionne localement avec Uvicorn.

Le fichier compose.yaml est valide avec `docker compose config`.

Le lancement avec Docker est bloqué par un problème de droits sur `/var/run/docker.sock` et par le fait que le plugin Compose est installé dans le dossier utilisateur.

Conclusion : le problème vient de l’environnement Fedora/Docker, pas du code de l’application.

Prochaine action : continuer l’apprentissage avec l’API locale, puis revenir sur Docker après avoir clarifié l’installation système.

## Étape Docker Compose

J’ai réussi à lancer ma mini API FastAPI dans un conteneur Docker avec Docker Compose.

Commande utilisée :

docker compose up --build -d

Ce que j’ai compris :

- Dockerfile décrit comment construire l’image de l’application.
- compose.yaml décrit comment lancer le service.
- docker compose config vérifie la configuration.
- docker compose up --build -d construit et lance le conteneur.
- docker compose ps vérifie si le conteneur tourne.
- docker compose logs permet de lire les logs.
- curl /health permet de vérifier que l’API répond.

Problème rencontré :

Docker Compose n’était pas immédiatement disponible sur ma machine Fedora.
Il a fallu corriger l’installation du plugin Compose et les droits d’accès Docker.

Conclusion :

Le problème ne venait pas du code de l’application mais de l’environnement Docker local.
