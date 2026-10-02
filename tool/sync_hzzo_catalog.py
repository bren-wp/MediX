#!/usr/bin/env python3
"""Build MediX's normalized HZZO medicine catalog from the public HZZO search.

The output contains administrative/reimbursement data only. It deliberately
does not invent clinical indications, contraindications, adverse effects or
dosing information that are not present in this source.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable
from urllib.parse import parse_qs, urlparse

import requests
from bs4 import BeautifulSoup, Tag

BASE_URL = "https://hzzo.hr/trazilica-za-lijekove"
EFFECTIVE_DATE = "2026-10-01"
MIN_EXPECTED_RECORDS = 1000
FALLBACK_MAX_PAGES = 1000

LABELS = [
    "ATK šifra",
    "Nezaštićeni naziv",
    "Način primjene",
    "Nositelj odobrenja",
    "Zaštićeni naziv",
    "Oblik, jačina i pakiranje",
    "Oznaka ograničenja primjene",
    "PSL",
    "R/RS",
    "Oznaka smjernice s kriterijima za propisivanje na recept",
    "Stopa PDV-a",
    "Osnovna lista lijekova",
    "Dopunska lista lijekova",
    "Doplata u EUR za orig. pak.",
]

ATC_CATEGORIES = {
    "A": "Probavni sustav i metabolizam",
    "B": "Krv i krvotvorni organi",
    "C": "Srce i krvožilni sustav",
    "D": "Dermatološki lijekovi",
    "G": "Mokraćni i spolni sustav",
    "H": "Hormonski lijekovi",
    "J": "Antiinfektivni lijekovi",
    "L": "Antineoplastici i imunomodulatori",
    "M": "Mišićno-koštani sustav",
    "N": "Živčani sustav",
    "P": "Antiparazitici",
    "R": "Dišni sustav",
    "S": "Osjetila",
    "V": "Ostali lijekovi",
}

STRENGTH_RE = re.compile(
    r"(\d+(?:[.,]\d+)?\s*(?:mg|g|µg|mcg|mikrograma|ml|mmol|IU|i\.j\.|%)(?:\s*/\s*\d+(?:[.,]\d+)?\s*(?:ml|g))?)",
    re.IGNORECASE,
)


def clean(value: str | None) -> str:
    return re.sub(r"\s+", " ", value or "").strip()


def slug(value: str) -> str:
    normalized = re.sub(r"[^a-zA-Z0-9]+", "-", value.lower()).strip("-")
    if normalized:
        return normalized[:100]
    return hashlib.sha1(value.encode("utf-8")).hexdigest()[:20]


def category_for(atc: str) -> str:
    first = clean(atc)[:1].upper()
    return ATC_CATEGORIES.get(first, "Ostali lijekovi")


def derive_form(package: str) -> str:
    text = clean(package)
    if not text:
        return "lijek"
    prefix = re.split(r"\d", text, maxsplit=1)[0].strip(" ,.-")
    return prefix[:80] if prefix else "lijek"


def derive_strength(package: str) -> str:
    match = STRENGTH_RE.search(package or "")
    return clean(match.group(1)) if match else clean(package)[:120]


def parse_number(value: str | None) -> float | None:
    text = clean(value).replace(",", ".")
    match = re.search(r"-?\d+(?:\.\d+)?", text)
    if not match:
        return None
    try:
        return float(match.group(0))
    except ValueError:
        return None


def split_label(text: str) -> tuple[str, str] | None:
    text = clean(text)
    for label in sorted(LABELS, key=len, reverse=True):
        if text.startswith(label):
            return label, clean(text[len(label) :])
    return None


def block_lines(heading: Tag) -> list[str]:
    lines: list[str] = []
    for element in heading.next_elements:
        if element is heading:
            continue
        if isinstance(element, Tag) and element.name in {"h2", "h3"}:
            break
        if isinstance(element, Tag) and element.name == "li":
            value = clean(element.get_text(" ", strip=True))
            if value:
                lines.append(value)
    return lines


def parse_page(html: str) -> list[dict]:
    soup = BeautifulSoup(html, "html.parser")
    result_heading = soup.find(
        lambda tag: isinstance(tag, Tag)
        and tag.name == "h2"
        and "Rezultati pretrage" in clean(tag.get_text(" ", strip=True))
    )
    if result_heading is None:
        raise RuntimeError("HZZO page structure changed: result heading not found.")

    records: list[dict] = []
    for heading in result_heading.find_all_next("h3"):
        title = clean(heading.get_text(" ", strip=True))
        if title.lower() == "pretraga":
            break

        fields: dict[str, str] = {}
        for line in block_lines(heading):
            pair = split_label(line)
            if pair is not None:
                fields[pair[0]] = pair[1]

        if "ATK šifra" not in fields or "Nezaštićeni naziv" not in fields:
            continue

        atc = clean(fields.get("ATK šifra"))
        generic = clean(fields.get("Nezaštićeni naziv"))

        # HZZO search also contains reimbursed medical nutrition and other
        # non-medicine products. They may enrich MediX only when matched to a
        # HALMED medicine and must never become medicine identities.
        if atc.upper().startswith("V06D"):
            continue
        if "namirnice bez glutena" in generic.casefold():
            continue
        protected = clean(fields.get("Zaštićeni naziv")) or title.split(" (", 1)[0]
        package = clean(fields.get("Oblik, jačina i pakiranje"))
        basic = clean(fields.get("Osnovna lista lijekova")).lower() == "da"
        supplementary = (
            clean(fields.get("Dopunska lista lijekova")).lower() == "da"
        )
        copay = parse_number(fields.get("Doplata u EUR za orig. pak."))

        unique_basis = f"{atc}|{protected}|{package}"
        record = {
            "id": f"hzzo-{slug(unique_basis)}",
            "name": protected or title,
            "active_ingredient": generic,
            "atc_code": atc,
            "category": category_for(atc),
            "route": clean(fields.get("Način primjene")),
            "holder": clean(fields.get("Nositelj odobrenja")),
            "protected_name": protected,
            "package": package,
            "form": derive_form(package),
            "strength": derive_strength(package),
            "restriction": clean(fields.get("Oznaka ograničenja primjene")),
            "psl": clean(fields.get("PSL")),
            "rx_status": clean(fields.get("R/RS")),
            "guideline": clean(
                fields.get(
                    "Oznaka smjernice s kriterijima za propisivanje na recept"
                )
            ),
            "vat_rate": clean(fields.get("Stopa PDV-a")),
            "basic_list": basic,
            "supplementary_list": supplementary,
            "copay_eur": copay,
            "source_url": BASE_URL,
            "effective_date": EFFECTIVE_DATE,
        }
        records.append(record)

    return records



def discover_last_page(html: str) -> int | None:
    """Return the highest zero-based HZZO page number advertised by pagination."""
    soup = BeautifulSoup(html, "html.parser")
    pages: list[int] = []
    for link in soup.find_all("a", href=True):
        href = link.get("href") or ""
        query = parse_qs(urlparse(href).query)
        values = query.get("page")
        if not values:
            continue
        try:
            pages.append(int(values[0]))
        except (TypeError, ValueError):
            continue
    return max(pages) if pages else None

def fetch_all(max_pages: int, delay: float) -> list[dict]:
    session = requests.Session()
    session.headers.update(
        {
            "User-Agent": (
                "MediX-data-sync/0.2 "
                "(public HZZO catalog synchronization; "
                "https://github.com/bren-wp/MediX)"
            )
        }
    )

    by_id: dict[str, dict] = {}
    previous_signature: tuple[str, ...] | None = None
    empty_pages = 0

    first_response = session.get(
        BASE_URL,
        params={"page": 0, "query": ""},
        timeout=45,
    )
    first_response.raise_for_status()

    advertised_last_page = discover_last_page(first_response.text)
    if advertised_last_page is not None:
        total_pages = advertised_last_page + 1
        if total_pages > max_pages:
            raise RuntimeError(
                f"HZZO advertises {total_pages} pages, above safety cap "
                f"max_pages={max_pages}."
            )
    else:
        total_pages = max_pages

    print(
        "pagination="
        + (
            f"0..{advertised_last_page}"
            if advertised_last_page is not None
            else f"unknown, capped at {max_pages}"
        ),
        file=sys.stderr,
    )

    for page in range(total_pages):
        if page == 0:
            response = first_response
        else:
            response = session.get(
                BASE_URL,
                params={"page": page, "query": ""},
                timeout=45,
            )
            response.raise_for_status()

        records = parse_page(response.text)
        signature = tuple(record["id"] for record in records)

        if not records:
            empty_pages += 1
            if empty_pages >= 2:
                print(f"Stopping after empty page {page}.", file=sys.stderr)
                break
        else:
            empty_pages = 0

        if signature and signature == previous_signature:
            print(
                f"Stopping at repeated page signature {page}.",
                file=sys.stderr,
            )
            break
        previous_signature = signature

        before = len(by_id)
        for record in records:
            by_id[record["id"]] = record
        added = len(by_id) - before

        print(
            f"page={page} parsed={len(records)} new={added} total={len(by_id)}",
            file=sys.stderr,
        )

        if delay > 0:
            time.sleep(delay)
    else:
        if advertised_last_page is None:
            raise RuntimeError(
                f"Reached max_pages={max_pages} before detecting the end."
            )

    return sorted(
        by_id.values(),
        key=lambda item: (
            item["name"].casefold(),
            item["atc_code"],
            item["package"],
        ),
    )


def write_catalog(records: Iterable[dict], output: Path) -> None:
    record_list = list(records)
    payload = {
        "schema_version": 1,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source": {
            "name": "HZZO Tražilica za lijekove",
            "url": BASE_URL,
            "effective_date": EFFECTIVE_DATE,
            "scope": (
                "Lijekovi prikazani u javnoj HZZO tražilici. "
                "Kliničke informacije moraju se nadopuniti iz "
                "eLijekovi/HALMED regulatornih izvora."
            ),
        },
        "record_count": len(record_list),
        "records": record_list,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        default="assets/data/hzzo_reimbursement.json",
        type=Path,
    )
    parser.add_argument("--max-pages", default=FALLBACK_MAX_PAGES, type=int)
    parser.add_argument("--delay", default=0.05, type=float)
    parser.add_argument(
        "--minimum-records",
        default=MIN_EXPECTED_RECORDS,
        type=int,
    )
    args = parser.parse_args()

    records = fetch_all(args.max_pages, args.delay)
    if len(records) < args.minimum_records:
        raise RuntimeError(
            "Refusing to replace catalog: "
            f"only {len(records)} records were parsed; "
            f"minimum is {args.minimum_records}."
        )

    write_catalog(records, args.output)
    print(f"Wrote {len(records)} records to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
