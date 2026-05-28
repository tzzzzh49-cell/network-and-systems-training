# Roadmap

## v0.1.0 — Reproduction locale stable

Objectif : stabiliser la base locale du projet.

Inclus :
- API FastAPI minimale ;
- Docker Compose fonctionnel ;
- Makefile utilisable ;
- documentation initiale ;
- reproduction Fedora 44 validée ;
- règles de sécurité en lecture seule.

## v0.2.0 — Tests, lint et CI

Objectif : rendre le projet vérifiable automatiquement.

Prévu :
- tests avec pytest ;
- lint Python avec ruff ;
- vérification des scripts Bash avec shellcheck ;
- validation Docker Compose ;
- GitHub Actions.

## v0.3.0 — Diagnostic réseau avancé

Objectif : enrichir le diagnostic système/réseau.

Prévu :
- collecte interfaces réseau ;
- routes ;
- DNS ;
- ports ouverts ;
- export JSON ;
- export Markdown.

## v0.4.0 — Déploiement VPS

Objectif : déployer le lab sur un VPS sécurisé.

Prévu :
- SSH sécurisé ;
- firewall ;
- Docker Compose distant ;
- HTTPS ;
- nom de domaine ;
- premiers backups.

## v0.5.0 — Résumé IA

Objectif : intégrer progressivement l’API OpenAI.

Prévu :
- résumé de rapports ;
- explication d’erreurs ;
- budget API limité ;
- absence d’exécution automatique de commandes.

## v0.6.0 — OpenClaw contrôlé

Objectif : intégrer OpenClaw avec sécurité.

Prévu :
- allowlist stricte ;
- runbooks ;
- mode lecture seule ;
- sandbox ;
- validation humaine.
