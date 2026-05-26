 # Network and Systems Training

Projet d’apprentissage autour de Linux, des réseaux, de Docker, de FastAPI, de l’automatisation et de la cybersécurité défensive.

L’objectif est de construire progressivement un lab capable de :

- exposer une API FastAPI minimale ;
- lancer des diagnostics système et réseau en lecture seule ;
- produire des rapports techniques ;
- être déployé plus tard sur un VPS ;
- intégrer progressivement les API OpenAI et OpenClaw de manière sécurisée.

## Statut actuel

- Reproduction testée sur une VM Fedora 44
- API FastAPI fonctionnelle
- Docker Compose fonctionnel
- Makefile en cours de stabilisation
- Documentation en cours
- Tests automatisés prévus au deuxième mois

## Sécurité

Le projet démarre volontairement en mode lecture seule.  
Aucune commande destructive ne doit être automatisée à ce stade.

## Démarrage rapide

```bash
git clone <url-du-repo>
cd network-and-systems-training
make build
make up
make health
make version
make diag
make down
```

## Commandes disponibles

| Commande | Description |
|---|---|
| `make help` | Affiche les commandes disponibles |
| `make build` | Construit l’image Docker |
| `make up` | Lance l’application |
| `make health` | Vérifie `/health` |
| `make version` | Vérifie `/version` |
| `make diag` | Vérifie `/diag` |
| `make logs` | Affiche les logs Docker |
| `make down` | Arrête l’application |

## Documentation

- [Architecture](docs/architecture.md)
- [Sécurité](docs/securite.md)
- [Reproductibilité Fedora 44](docs/reproductibilite-fedora-44-vm.md)
- [Journal d’apprentissage](docs/journal-apprentissage.md)
- [ADR-001 — Mode lecture seule](docs/decisions/ADR-001-mode-read-only.md)

Le projet est documenté progressivement afin de montrer les choix techniques, les règles de sécurité et les apprentissages réalisés.
