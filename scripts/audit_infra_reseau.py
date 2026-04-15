#!/usr/bin/env python3
"""Audit d'infrastructure réseau (niveau ingénieur) en Python.

Objectifs pédagogiques:
- Montrer une architecture claire (collecte -> analyse -> restitution)
- Exécuter des vérifications en parallèle
- Produire un rapport JSON exploitable en automatisation
- Illustrer les couches réseau (L2/L3/L4 + DNS)

Aucune dépendance externe n'est requise (stdlib uniquement).
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import platform
import re
import shutil
import socket
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Iterable


# ---------------------------
# Modèle de données du rapport
# ---------------------------


@dataclass
class CommandResult:
    command: str
    returncode: int
    stdout: str
    stderr: str
    duration_ms: int


@dataclass
class CheckResult:
    name: str
    status: str  # ok | warning | fail | skipped
    summary: str
    details: dict = field(default_factory=dict)


@dataclass
class AuditReport:
    generated_at: str
    host: str
    os: str
    kernel: str
    checks: list[CheckResult]

    def to_json(self) -> str:
        return json.dumps(asdict(self), indent=2, ensure_ascii=False)


# ---------------------------
# Outils bas niveau
# ---------------------------


def run_cmd(command: list[str], timeout: int = 6) -> CommandResult:
    """Exécute une commande shell de manière contrôlée."""
    started = time.perf_counter()
    try:
        completed = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
        duration = int((time.perf_counter() - started) * 1000)
        return CommandResult(
            command=" ".join(command),
            returncode=completed.returncode,
            stdout=completed.stdout.strip(),
            stderr=completed.stderr.strip(),
            duration_ms=duration,
        )
    except subprocess.TimeoutExpired as exc:
        duration = int((time.perf_counter() - started) * 1000)
        return CommandResult(
            command=" ".join(command),
            returncode=124,
            stdout=(exc.stdout or "").strip() if exc.stdout else "",
            stderr=f"Timeout après {timeout}s",
            duration_ms=duration,
        )


def command_exists(name: str) -> bool:
    return shutil.which(name) is not None


# ---------------------------
# Vérifications (checks)
# ---------------------------


def check_network_interfaces() -> CheckResult:
    """Inspecte les interfaces réseau Linux via /sys/class/net."""
    net_dir = Path("/sys/class/net")
    if not net_dir.exists():
        return CheckResult(
            name="interfaces",
            status="skipped",
            summary="/sys/class/net indisponible sur ce système.",
        )

    interfaces = []
    for iface in sorted(net_dir.iterdir()):
        try:
            state = (iface / "operstate").read_text().strip()
        except OSError:
            state = "unknown"
        try:
            mac = (iface / "address").read_text().strip()
        except OSError:
            mac = "n/a"
        interfaces.append({"name": iface.name, "state": state, "mac": mac})

    up = [i for i in interfaces if i["state"] == "up"]
    status = "ok" if up else "warning"
    return CheckResult(
        name="interfaces",
        status=status,
        summary=f"{len(interfaces)} interface(s), {len(up)} active(s).",
        details={"interfaces": interfaces},
    )


def check_ip_configuration() -> CheckResult:
    """Collecte les adresses IP locales avec `ip addr` (Linux)."""
    if not command_exists("ip"):
        return CheckResult(
            name="ip_config",
            status="skipped",
            summary="Commande `ip` introuvable.",
        )

    res = run_cmd(["ip", "-brief", "addr", "show"])
    if res.returncode != 0:
        return CheckResult(
            name="ip_config",
            status="fail",
            summary="Impossible de lire la configuration IP.",
            details={"command": asdict(res)},
        )

    lines = [line for line in res.stdout.splitlines() if line.strip()]
    ipv4_re = re.compile(r"\b\d{1,3}(?:\.\d{1,3}){3}/\d{1,2}\b")
    ipv4_count = sum(len(ipv4_re.findall(line)) for line in lines)

    return CheckResult(
        name="ip_config",
        status="ok" if lines else "warning",
        summary=f"{len(lines)} interface(s) listée(s), {ipv4_count} IPv4 détectée(s).",
        details={"raw": lines, "command": asdict(res)},
    )


def check_default_route() -> CheckResult:
    """Vérifie la présence d'une route par défaut."""
    if not command_exists("ip"):
        return CheckResult(
            name="default_route",
            status="skipped",
            summary="Commande `ip` introuvable.",
        )

    res = run_cmd(["ip", "route", "show", "default"])
    if res.returncode != 0:
        return CheckResult(
            name="default_route",
            status="fail",
            summary="Erreur lors de la lecture de la table de routage.",
            details={"command": asdict(res)},
        )

    has_default = bool(res.stdout.strip())
    return CheckResult(
        name="default_route",
        status="ok" if has_default else "warning",
        summary="Route par défaut détectée." if has_default else "Aucune route par défaut.",
        details={"route": res.stdout.splitlines(), "command": asdict(res)},
    )


def check_dns_resolution(hostname: str) -> CheckResult:
    """Teste la résolution DNS côté client."""
    try:
        started = time.perf_counter()
        infos = socket.getaddrinfo(hostname, None)
        duration = int((time.perf_counter() - started) * 1000)
    except socket.gaierror as exc:
        return CheckResult(
            name=f"dns:{hostname}",
            status="fail",
            summary=f"Résolution DNS échouée pour {hostname}.",
            details={"error": str(exc)},
        )

    ips = sorted({entry[4][0] for entry in infos})
    return CheckResult(
        name=f"dns:{hostname}",
        status="ok",
        summary=f"{hostname} résolu en {len(ips)} IP.",
        details={"ips": ips, "duration_ms": duration},
    )


def check_tcp_port(host: str, port: int, timeout: float = 2.0) -> CheckResult:
    """Vérifie la connectivité TCP (couche 4)."""
    started = time.perf_counter()
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(timeout)
    try:
        code = sock.connect_ex((host, port))
    except OSError as exc:
        duration = int((time.perf_counter() - started) * 1000)
        return CheckResult(
            name=f"tcp:{host}:{port}",
            status="fail",
            summary=f"Erreur TCP vers {host}:{port}.",
            details={"error": str(exc), "duration_ms": duration},
        )
    finally:
        sock.close()

    duration = int((time.perf_counter() - started) * 1000)
    if code == 0:
        return CheckResult(
            name=f"tcp:{host}:{port}",
            status="ok",
            summary=f"Port {port} joignable sur {host}.",
            details={"duration_ms": duration},
        )

    return CheckResult(
        name=f"tcp:{host}:{port}",
        status="warning",
        summary=f"Port {port} inaccessible sur {host} (code={code}).",
        details={"errno": code, "duration_ms": duration},
    )


def check_ping(host: str, count: int = 2) -> CheckResult:
    """Teste la reachability ICMP (si la commande ping existe)."""
    if not command_exists("ping"):
        return CheckResult(
            name=f"ping:{host}",
            status="skipped",
            summary="Commande ping introuvable.",
        )

    res = run_cmd(["ping", "-c", str(count), "-W", "1", host], timeout=8)
    status = "ok" if res.returncode == 0 else "warning"
    summary = (
        f"Ping réussi vers {host}."
        if res.returncode == 0
        else f"Ping échoué vers {host}."
    )
    return CheckResult(
        name=f"ping:{host}",
        status=status,
        summary=summary,
        details={"command": asdict(res)},
    )


# ---------------------------
# Orchestration
# ---------------------------


def run_checks(targets: Iterable[str], tcp_ports: Iterable[int], dns_hosts: Iterable[str]) -> list[CheckResult]:
    """Lance les checks de base + checks cibles en parallèle."""
    checks: list[CheckResult] = [
        check_network_interfaces(),
        check_ip_configuration(),
        check_default_route(),
    ]

    tasks = []
    with ThreadPoolExecutor(max_workers=12) as pool:
        for target in targets:
            tasks.append(pool.submit(check_ping, target))
            for port in tcp_ports:
                tasks.append(pool.submit(check_tcp_port, target, port))

        for dns_name in dns_hosts:
            tasks.append(pool.submit(check_dns_resolution, dns_name))

        for future in as_completed(tasks):
            checks.append(future.result())

    return sorted(checks, key=lambda c: c.name)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Audit réseau automatisé (inspiration ingénierie infrastructure)."
    )
    parser.add_argument(
        "--targets",
        nargs="*",
        default=["1.1.1.1", "8.8.8.8"],
        help="Hôtes/IP à tester en ping et TCP.",
    )
    parser.add_argument(
        "--ports",
        nargs="*",
        type=int,
        default=[53, 80, 443],
        help="Ports TCP à vérifier sur chaque target.",
    )
    parser.add_argument(
        "--dns",
        nargs="*",
        default=["openai.com", "cloudflare.com"],
        help="Noms DNS à résoudre.",
    )
    parser.add_argument(
        "--output",
        default="-",
        help="Fichier JSON de sortie ('-' pour stdout).",
    )
    parser.add_argument(
        "--fail-on",
        choices=["never", "warning", "fail"],
        default="fail",
        help="Code de sortie non nul si un statut >= seuil est détecté.",
    )
    return parser


def exit_code_from_checks(checks: list[CheckResult], fail_on: str) -> int:
    severities = {"ok": 0, "skipped": 0, "warning": 1, "fail": 2}
    threshold = {"never": 99, "warning": 1, "fail": 2}[fail_on]
    max_seen = max((severities.get(c.status, 0) for c in checks), default=0)
    return 1 if max_seen >= threshold else 0


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    report = AuditReport(
        generated_at=dt.datetime.now(dt.timezone.utc).isoformat(),
        host=socket.gethostname(),
        os=platform.platform(),
        kernel=platform.release(),
        checks=run_checks(args.targets, args.ports, args.dns),
    )
    payload = report.to_json()

    if args.output == "-":
        print(payload)
    else:
        Path(args.output).write_text(payload + "\n", encoding="utf-8")
        print(f"Rapport écrit dans {args.output}")

    return exit_code_from_checks(report.checks, args.fail_on)


if __name__ == "__main__":
    sys.exit(main())
