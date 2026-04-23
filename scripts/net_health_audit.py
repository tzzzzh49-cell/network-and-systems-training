#!/usr/bin/env python3
"""
Audit santé + découverte de topologie pour un débutant en administration réseau.

Objectifs pédagogiques :
1) Observer l'état système local (CPU, mémoire, disque, services, interfaces).
2) Tester la connectivité vers des cibles connues (ping + traceroute).
3) Découvrir des voisins réseau (scan simple + table ARP/NDP).
4) Générer un rapport JSON + un fichier Graphviz DOT pour visualiser la topologie.
"""

from __future__ import annotations

import argparse
import ipaddress
import json
import platform
import shutil
import socket
import subprocess
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


@dataclass
class CommandResult:
    """Structure de retour unifiée pour les commandes shell."""

    ok: bool
    command: list[str]
    stdout: str
    stderr: str
    returncode: int


def run_command(command: list[str], timeout: int = 10) -> CommandResult:
    """
    Exécute une commande shell sans lever d'exception bloquante.

    Pourquoi ?
    - En admin système, certaines commandes peuvent manquer selon l'OS.
    - On préfère collecter un maximum d'informations plutôt qu'échouer au 1er problème.
    """
    try:
        completed = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
        return CommandResult(
            ok=completed.returncode == 0,
            command=command,
            stdout=completed.stdout.strip(),
            stderr=completed.stderr.strip(),
            returncode=completed.returncode,
        )
    except (subprocess.TimeoutExpired, FileNotFoundError) as exc:
        return CommandResult(
            ok=False,
            command=command,
            stdout="",
            stderr=str(exc),
            returncode=124,
        )


class HealthCollector:
    """Collecte les indicateurs de santé de la machine locale."""

    def collect_system_profile(self) -> dict[str, Any]:
        return {
            "hostname": socket.gethostname(),
            "fqdn": socket.getfqdn(),
            "os": platform.platform(),
            "kernel": platform.release(),
            "python": platform.python_version(),
            "utc_collected_at": datetime.now(timezone.utc).isoformat(),
        }

    def collect_uptime(self) -> dict[str, Any]:
        if Path("/proc/uptime").exists():
            raw = Path("/proc/uptime").read_text(encoding="utf-8").split()[0]
            seconds = float(raw)
            return {"uptime_seconds": seconds, "uptime_hours": round(seconds / 3600, 2)}

        uptime_cmd = run_command(["uptime", "-p"])
        return {
            "uptime_pretty": uptime_cmd.stdout,
            "source": "uptime -p",
            "errors": uptime_cmd.stderr if not uptime_cmd.ok else "",
        }

    def collect_load_average(self) -> dict[str, Any]:
        if Path("/proc/loadavg").exists():
            load = Path("/proc/loadavg").read_text(encoding="utf-8").split()[:3]
            return {"1m": float(load[0]), "5m": float(load[1]), "15m": float(load[2])}

        return {"warning": "load average non disponible sur cet OS"}

    def collect_memory(self) -> dict[str, Any]:
        if not Path("/proc/meminfo").exists():
            return {"warning": "meminfo non disponible"}

        fields: dict[str, int] = {}
        for line in Path("/proc/meminfo").read_text(encoding="utf-8").splitlines():
            key, val = line.split(":", 1)
            fields[key] = int(val.strip().split()[0])  # kB

        total = fields.get("MemTotal", 0)
        available = fields.get("MemAvailable", 0)
        used = max(total - available, 0)
        usage_pct = round((used / total) * 100, 2) if total else None
        return {
            "total_kb": total,
            "available_kb": available,
            "used_kb": used,
            "usage_pct": usage_pct,
        }

    def collect_disk(self) -> dict[str, Any]:
        df_json = run_command(["df", "-PTh"])
        return {
            "raw_table": df_json.stdout.splitlines(),
            "source": "df -PTh",
            "errors": df_json.stderr if not df_json.ok else "",
        }

    def collect_interfaces(self) -> dict[str, Any]:
        ip_json = run_command(["ip", "-j", "addr"])
        parsed: list[dict[str, Any]] = []

        if ip_json.ok and ip_json.stdout:
            try:
                data = json.loads(ip_json.stdout)
                for iface in data:
                    parsed.append(
                        {
                            "name": iface.get("ifname"),
                            "state": iface.get("operstate"),
                            "mac": iface.get("address"),
                            "addresses": [
                                {
                                    "family": addr.get("family"),
                                    "local": addr.get("local"),
                                    "prefixlen": addr.get("prefixlen"),
                                }
                                for addr in iface.get("addr_info", [])
                            ],
                        }
                    )
            except json.JSONDecodeError:
                pass

        return {
            "interfaces": parsed,
            "raw": ip_json.stdout.splitlines() if not parsed else [],
            "errors": ip_json.stderr if not ip_json.ok else "",
        }

    def collect_routes(self) -> dict[str, Any]:
        route_cmd = run_command(["ip", "route"])
        return {
            "routes": route_cmd.stdout.splitlines(),
            "source": "ip route",
            "errors": route_cmd.stderr if not route_cmd.ok else "",
        }

    def collect_dns(self) -> dict[str, Any]:
        resolv = Path("/etc/resolv.conf")
        if not resolv.exists():
            return {"warning": "/etc/resolv.conf introuvable"}

        nameservers: list[str] = []
        search_domains: list[str] = []
        for line in resolv.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if line.startswith("nameserver"):
                nameservers.append(line.split()[1])
            if line.startswith("search"):
                search_domains.extend(line.split()[1:])

        return {"nameservers": nameservers, "search_domains": search_domains}


class TopologyCollector:
    """Collecte d'indices permettant de dessiner une topologie réseau."""

    def __init__(self, ping_timeout: int = 1):
        self.ping_timeout = ping_timeout

    def ping_target(self, target: str) -> dict[str, Any]:
        cmd = ["ping", "-c", "1", "-W", str(self.ping_timeout), target]
        result = run_command(cmd, timeout=self.ping_timeout + 4)
        return {
            "target": target,
            "reachable": result.ok,
            "returncode": result.returncode,
            "stdout": result.stdout,
            "stderr": result.stderr,
        }

    def traceroute_target(self, target: str, max_hops: int = 12) -> dict[str, Any]:
        if not shutil.which("traceroute"):
            return {"target": target, "warning": "traceroute non installé"}

        cmd = ["traceroute", "-n", "-m", str(max_hops), target]
        result = run_command(cmd, timeout=30)
        hops: list[str] = []
        if result.stdout:
            for line in result.stdout.splitlines()[1:]:
                parts = line.split()
                if len(parts) >= 2:
                    hops.append(parts[1])

        return {
            "target": target,
            "ok": result.ok,
            "hops": hops,
            "stdout": result.stdout,
            "stderr": result.stderr,
        }

    def get_arp_neighbors(self) -> dict[str, Any]:
        neigh_cmd = run_command(["ip", "neigh"])
        neighbors = []
        for line in neigh_cmd.stdout.splitlines():
            # Exemple: 192.168.1.10 dev eth0 lladdr aa:bb:cc:dd:ee:ff REACHABLE
            parts = line.split()
            if len(parts) >= 4:
                neighbors.append(
                    {
                        "ip": parts[0],
                        "dev": parts[2],
                        "mac": parts[4] if "lladdr" in parts else None,
                        "state": parts[-1],
                    }
                )

        return {
            "neighbors": neighbors,
            "source": "ip neigh",
            "errors": neigh_cmd.stderr if not neigh_cmd.ok else "",
        }

    def _candidate_subnets_from_interfaces(
        self, interfaces: list[dict[str, Any]]
    ) -> list[ipaddress.IPv4Network]:
        candidates: list[ipaddress.IPv4Network] = []
        for iface in interfaces:
            for addr in iface.get("addresses", []):
                if addr.get("family") != "inet":
                    continue
                local = addr.get("local")
                prefix = addr.get("prefixlen")
                if not local or prefix is None:
                    continue
                try:
                    network = ipaddress.ip_interface(f"{local}/{prefix}").network
                except ValueError:
                    continue
                if isinstance(network, ipaddress.IPv4Network):
                    candidates.append(network)
        return candidates

    def discover_hosts(
        self,
        interfaces: list[dict[str, Any]],
        max_hosts_per_subnet: int = 64,
    ) -> dict[str, Any]:
        """
        Scan ping très simple (et volontairement limité) pour éviter d'inonder le réseau.
        """
        networks = self._candidate_subnets_from_interfaces(interfaces)
        discoveries: list[dict[str, Any]] = []

        for network in networks:
            hosts = list(network.hosts())[:max_hosts_per_subnet]
            reachable: list[str] = []
            for host in hosts:
                probe = self.ping_target(str(host))
                if probe["reachable"]:
                    reachable.append(str(host))

            discoveries.append(
                {
                    "subnet": str(network),
                    "tested_hosts": len(hosts),
                    "reachable_hosts": reachable,
                }
            )

        return {"subnet_discovery": discoveries}


def build_graphviz_topology(report: dict[str, Any]) -> str:
    """Construit un fichier .dot simple pour Graphviz."""
    hostname = report["health"]["system_profile"].get("hostname", "local-host")
    nodes: set[str] = {hostname}
    edges: set[tuple[str, str, str]] = set()

    for ping_result in report["topology"].get("ping_targets", []):
        target = ping_result.get("target")
        if target:
            nodes.add(target)
            status = "up" if ping_result.get("reachable") else "down"
            edges.add((hostname, target, status))

    for neighbor in report["topology"].get("arp_neighbors", {}).get("neighbors", []):
        ip = neighbor.get("ip")
        if ip:
            nodes.add(ip)
            edges.add((hostname, ip, f"arp:{neighbor.get('state', 'unknown')}"))

    lines = ["graph topology {", '  rankdir="LR";', '  node [shape=ellipse, fontsize=10];']

    for node in sorted(nodes):
        if node == hostname:
            lines.append(f'  "{node}" [shape=box, style="filled", fillcolor="#D6EAF8"];')
        else:
            lines.append(f'  "{node}";')

    for src, dst, label in sorted(edges):
        lines.append(f'  "{src}" -- "{dst}" [label="{label}"];')

    lines.append("}")
    return "\n".join(lines)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Audit santé + collecte topologie (JSON + Graphviz DOT)."
    )
    parser.add_argument(
        "--target",
        action="append",
        default=["8.8.8.8", "1.1.1.1"],
        help="Cible à tester en ping/traceroute. Répéter l'option pour plusieurs cibles.",
    )
    parser.add_argument(
        "--output-dir",
        default="outputs",
        help="Dossier de sortie pour les rapports.",
    )
    parser.add_argument(
        "--scan",
        action="store_true",
        help="Active un scan ping limité des sous-réseaux locaux détectés.",
    )
    parser.add_argument(
        "--max-scan-hosts",
        type=int,
        default=32,
        help="Nombre max d'hôtes testés par sous-réseau en mode --scan.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    health = HealthCollector()
    topo = TopologyCollector()

    interfaces_data = health.collect_interfaces()

    report: dict[str, Any] = {
        "health": {
            "system_profile": health.collect_system_profile(),
            "uptime": health.collect_uptime(),
            "load_average": health.collect_load_average(),
            "memory": health.collect_memory(),
            "disk": health.collect_disk(),
            "interfaces": interfaces_data,
            "routes": health.collect_routes(),
            "dns": health.collect_dns(),
        },
        "topology": {
            "ping_targets": [topo.ping_target(t) for t in args.target],
            "traceroutes": [topo.traceroute_target(t) for t in args.target],
            "arp_neighbors": topo.get_arp_neighbors(),
        },
    }

    if args.scan:
        report["topology"]["subnet_scan"] = topo.discover_hosts(
            interfaces_data.get("interfaces", []), max_hosts_per_subnet=args.max_scan_hosts
        )

    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    report_file = output_dir / f"health-topology-report-{timestamp}.json"
    dot_file = output_dir / f"topology-{timestamp}.dot"

    report_file.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    dot_file.write_text(build_graphviz_topology(report), encoding="utf-8")

    print("=== Audit terminé ===")
    print(f"Rapport JSON : {report_file}")
    print(f"Topologie DOT : {dot_file}")
    print("Astuce: si graphviz est installé, lance:")
    print(f"  dot -Tpng {dot_file} -o {dot_file.with_suffix('.png')}")


if __name__ == "__main__":
    main()
