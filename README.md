# Linux Network Fundamentals

Ce dépôt inclut un script Python d'audit d'infrastructure réseau conçu comme **modèle pédagogique** pour un profil junior en systèmes/réseaux.

## Script principal

- `scripts/audit_infra_reseau.py`

### Ce que le script montre

- Structuration « ingénierie » en couches: collecte, checks, orchestration, rapport.
- Utilisation de `dataclasses` pour un modèle de données propre.
- Exécution parallèle des tests (`ThreadPoolExecutor`).
- Vérifications multi-couches:
  - Interfaces réseau (L2/L3)
  - Configuration IP et route par défaut (L3)
  - DNS (`socket.getaddrinfo`)
  - Connectivité TCP (L4)
  - Ping ICMP
- Sortie JSON directement exploitable en automatisation (CI/CD, supervision, ticketing).

## Exemples d'utilisation

```bash
# Exécution par défaut (stdout JSON)
python3 scripts/audit_infra_reseau.py

# Vérifier des cibles spécifiques
python3 scripts/audit_infra_reseau.py \
  --targets 10.0.0.1 192.168.1.1 \
  --ports 22 80 443 \
  --dns google.com internal.example.com

# Écrire le rapport dans un fichier
python3 scripts/audit_infra_reseau.py --output rapport-reseau.json

# Forcer un code de retour non nul dès warning
python3 scripts/audit_infra_reseau.py --fail-on warning
```

## Idées d'extensions

- Ajouter des checks IPv6 avancés.
- Ajouter la lecture de targets depuis un inventaire YAML.
- Export Prometheus/OpenTelemetry.
- Intégration à Ansible/AWX ou GitLab CI.
