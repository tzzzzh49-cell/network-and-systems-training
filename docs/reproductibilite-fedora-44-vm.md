# Test de reproduction — Fedora 44 VM

**Date :** 2026-05-26  
**Machine :** VM Fedora 44 Workstation  
**Utilisateur :** thomas  
**Dépôt :** `network-and-systems-training`

## Objectif

Vérifier que le projet peut être cloné, lancé et testé depuis une installation propre.

## Commandes exécutées

```bash
git clone https://github.com/tzzzzh49-cell/network-and-systems-training.git
cd network-and-systems-training
make help
make build
make up
make health
make version
make diag
make down
````

## Résultat

La reproduction fonctionne après correction du chemin du script Fedora dans le `Makefile`.

Le `Makefile` utilise désormais :

```bash
./scripts/bootstrap_fedora44_vm.sh
```

## Points vérifiés

* Le dépôt se clone correctement ;
* Docker Compose construit l’application ;
* L’application démarre ;
* `/health` répond ;
* `/version` répond ;
* `/diag` répond ;
* L’application peut être arrêtée proprement.

## Problème rencontré

Une incohérence existait entre le `Makefile` local corrigé et la version présente sur GitHub.

## Correction

La branche contenant la correction a été intégrée dans `master`.

## Leçon apprise

Un projet peut fonctionner localement tout en étant différent de la version visible sur GitHub.

Il faut donc vérifier :

* La branche courante ;
* Les commits locaux ;
* Les commits distants ;
* Le résultat après `push` ;
* Le contenu réel affiché sur GitHub.
