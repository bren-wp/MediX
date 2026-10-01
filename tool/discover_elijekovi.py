#!/usr/bin/env python3
"""Discover public eLijekovi web/API endpoints without guessing data semantics."""

from __future__ import annotations

import re
from pathlib import Path
from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup

ROOT = "https://elijekovi-hzzo.gov.hr/"
REGISTERED = urljoin(ROOT, "RegisteredDrug")
OUTPUT = Path("docs/ELIJEKOVI_DISCOVERY.md")

URL_RE = re.compile(
    r"""(?:"|')((?:https?://[^"'\s]+)|(?:/[A-Za-z0-9_./?=&%-]+))(?:"|')"""
)
KEYWORDS = (
    "api",
    "drug",
    "registered",
    "medicine",
    "lijek",
    "search",
    "interact",
)


def interesting(value: str) -> bool:
    lower = value.lower()
    return any(keyword in lower for keyword in KEYWORDS)


def main() -> int:
    session = requests.Session()
    session.headers.update(
        {
            "User-Agent": (
                "MediX-source-discovery/0.2 "
                "(https://github.com/bren-wp/MediX)"
            )
        }
    )

    report = [
        "# eLijekovi public endpoint discovery",
        "",
        "Automatski tehnički izvještaj. Ne tumači medicinski sadržaj.",
        "",
    ]

    response = session.get(REGISTERED, timeout=60)
    report.extend(
        [
            f"- Requested: `{REGISTERED}`",
            f"- HTTP status: **{response.status_code}**",
            f"- Final URL: `{response.url}`",
            f"- Content-Type: `{response.headers.get('content-type', '')}`",
            "",
        ]
    )
    response.raise_for_status()

    soup = BeautifulSoup(response.text, "html.parser")
    scripts = []
    for tag in soup.find_all("script"):
        src = tag.get("src")
        if src:
            scripts.append(urljoin(response.url, src))

    report.append("## Script bundles")
    report.append("")
    if not scripts:
        report.append("- No external script bundles discovered.")
    else:
        for src in scripts:
            report.append(f"- `{src}`")
    report.append("")

    candidates: set[str] = set()
    for match in URL_RE.finditer(response.text):
        candidate = match.group(1)
        if interesting(candidate):
            candidates.add(urljoin(response.url, candidate))

    for src in scripts[:30]:
        try:
            js = session.get(src, timeout=60)
            js.raise_for_status()
        except requests.RequestException as exc:
            report.append(f"- Could not inspect `{src}`: {exc}")
            continue

        for match in URL_RE.finditer(js.text):
            candidate = match.group(1)
            if interesting(candidate):
                candidates.add(urljoin(src, candidate))

        for token in re.findall(
            r"[A-Za-z0-9_./-]{4,120}",
            js.text,
        ):
            if interesting(token) and (
                "RegisteredDrug" in token
                or "/api/" in token.lower()
                or "interaction" in token.lower()
            ):
                candidates.add(urljoin(src, token))

    report.extend(
        [
            "## Candidate public endpoints/routes",
            "",
        ]
    )
    if not candidates:
        report.append("- No candidates discovered automatically.")
    else:
        for candidate in sorted(candidates):
            report.append(f"- `{candidate}`")

    report.extend(
        [
            "",
            "## Next validation",
            "",
            "Candidates must be validated for public access, response schema, "
            "pagination and licensing/usage conditions before any data is "
            "bundled into MediX.",
            "",
        ]
    )

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text("\n".join(report), encoding="utf-8")
    print(f"Wrote {OUTPUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
