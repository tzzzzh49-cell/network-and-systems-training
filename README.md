# Audit Santé & Topologie Réseau (niveau débutant)

Ce mini-projet t'aide à apprendre **l'automatisation système/réseau** pas à pas.

Le programme fait 2 missions principales:

1. **Bilan santé du poste**
   - Profil système (OS, kernel, hostname)
   - Uptime
   - Charge CPU (load average)
   - Mémoire (`/proc/meminfo`)
   - Disques (`df -PTh`)
   - Interfaces réseau (`ip -j addr`)
   - Routes (`ip route`)
   - DNS (`/etc/resolv.conf`)

2. **Collecte topologie**
   - Ping de cibles (ex: 8.8.8.8)
   - Traceroute (si installé)
   - Voisins ARP/NDP (`ip neigh`)
   - Scan ping limité des sous-réseaux locaux (optionnel)
   - Export d'un graphe `.dot` (Graphviz)

---

## Structure

- `scripts/net_health_audit.py` → script principal (Python)
- `scripts/diag_reseau.sh` → lanceur Bash
- `outputs/` → rapports générés (`.json` + `.dot`)

---

## Exécution rapide

```bash
./scripts/diag_reseau.sh
```

Avec scan local limité:

```bash
./scripts/diag_reseau.sh --scan --max-scan-hosts 16 --target 192.168.1.1
```

Le script affiche les chemins de sortie:

- `outputs/health-topology-report-<timestamp>.json`
- `outputs/topology-<timestamp>.dot`

Si Graphviz est installé:

```bash
dot -Tpng outputs/topology-<timestamp>.dot -o outputs/topology-<timestamp>.png
```

---

## Comprendre le fonctionnement (très important)

### 1) Pourquoi `run_command()` ?

Dans la vraie vie admin, un outil peut manquer (`traceroute`, `ip`, etc.).
On évite de bloquer tout le programme: on capture l'erreur et on continue la collecte.

### 2) Partie "HealthCollector"

Chaque méthode lit une source différente:

- `collect_system_profile()` → infos Python/OS
- `collect_uptime()` → `/proc/uptime` (Linux)
- `collect_load_average()` → `/proc/loadavg`
- `collect_memory()` → `/proc/meminfo`
- `collect_disk()` → `df`
- `collect_interfaces()` → `ip -j addr` (JSON natif Linux)
- `collect_routes()` → `ip route`
- `collect_dns()` → `/etc/resolv.conf`

### 3) Partie "TopologyCollector"

- `ping_target()` teste si une cible répond.
- `traceroute_target()` récupère les sauts réseau.
- `get_arp_neighbors()` lit les voisins de couche 2/3.
- `discover_hosts()` construit les sous-réseaux locaux depuis les interfaces puis ping une liste **limitée** d'hôtes.

### 4) Génération topologie

`build_graphviz_topology()` transforme les informations en graphe `.dot`.
Ensuite Graphviz peut convertir en image `.png`.

---

## Bonnes pratiques (sécurité & éthique)

- Scanne uniquement des réseaux autorisés.
- Commence avec des limites basses (`--max-scan-hosts 16`).
- Exécute en labo (VM, réseau de test) avant production.

---

## Pour progresser vers Network Automation Engineer

Étapes conseillées:

1. Ajouter export CSV (en plus du JSON)
2. Ajouter seuils d'alerte (RAM > 90%, disque > 85%)
3. Envoyer le rapport vers une API (FastAPI/Flask)
4. Stocker dans une base (SQLite/PostgreSQL)
5. Planifier exécution automatique (cron / systemd timer)
6. Versionner + CI (GitHub Actions)

Tu peux me demander ensuite:
- une **version orientée entreprise** (multi-hôtes via SSH)
- une **version orientée supervision** (Prometheus/Grafana)
- une **version orientée cartographie** (NetBox + Nmap + LLDP)
