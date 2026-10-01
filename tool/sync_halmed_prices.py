#!/usr/bin/env python3
"""Synchronize HALMED's 2026 maximum permitted wholesale medicine prices."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path

import requests
from bs4 import BeautifulSoup

SOURCE_URL = (
    "https://narodne-novine.nn.hr/clanci/sluzbeni/2026_06_64_783.html"
)
PUBLISHED_DATE = "2026-06-18"
MIN_EXPECTED_RECORDS = 1000


def clean(value: str | None) -> str:
    return re.sub(r"\s+", " ", value or "").strip()


def parse_euro(value: str) -> float | None:
    text = clean(value)
    if "EUR" not in text.upper():
        return None
    number = re.sub(r"[^0-9,.-]", "", text)
    if not number:
        return None
    if "," in number:
        number = number.replace(".", "").replace(",", ".")
    try:
        return float(number)
    except ValueError:
        return None


def derive_name(name_and_package: str) -> str:
    text = clean(name_and_package)
    # Product names precede the first dosage strength in the official list.
    match = re.search(
        r"\s\d+(?:[.,]\d+)?\s*(?:mg|g|mikrograma|µg|mcg|IU|i\.j\.|%|jedinica)",
        text,
        flags=re.IGNORECASE,
    )
    if match:
        return text[: match.start()].strip(" ,")
    # Vaccines and some special products have no leading numeric strength.
    return text.split(",", 1)[0].strip()


def stable_id(approval: str, name_and_package: str) -> str:
    basis = f"{approval}|{name_and_package}".encode("utf-8")
    return "halmed-" + hashlib.sha1(basis).hexdigest()[:20]


def parse_table(html: str) -> list[dict]:
    soup = BeautifulSoup(html, "html.parser")
    records: list[dict] = []

    for table in soup.find_all("table"):
        for row in table.find_all("tr"):
            cells = [
                clean(cell.get_text(" ", strip=True))
                for cell in row.find_all(["td", "th"])
            ]
            if len(cells) < 8:
                continue

            price = parse_euro(cells[7])
            name_and_package = cells[0]
            active = cells[1] if len(cells) > 1 else ""
            atc = cells[2] if len(cells) > 2 else ""
            approval = cells[3] if len(cells) > 3 else ""
            holder = cells[4] if len(cells) > 4 else ""
            local_representative = cells[5] if len(cells) > 5 else ""
            parallel_holder = cells[6] if len(cells) > 6 else ""
            note = cells[8] if len(cells) > 8 else ""

            if not name_and_package or not active or not atc:
                continue
            if "Naziv lijeka" in name_and_package:
                continue

            records.append(
                {
                    "id": stable_id(approval, name_and_package),
                    "name": derive_name(name_and_package),
                    "name_and_package": name_and_package,
                    "active_ingredient": active,
                    "atc_code": atc,
                    "authorization_number": approval,
                    "holder": holder,
                    "local_representative": local_representative,
                    "parallel_trade_holder": parallel_holder,
                    "max_wholesale_eur": price,
                    "note": note,
                    "source_url": SOURCE_URL,
                    "published_date": PUBLISHED_DATE,
                }
            )

    # Some unusually formatted rows can occur more than once in accessible HTML.
    unique: dict[str, dict] = {}
    for record in records:
        unique[record["id"]] = record

    return sorted(
        unique.values(),
        key=lambda item: (
            item["name"].casefold(),
            item["authorization_number"],
            item["name_and_package"],
        ),
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("assets/data/halmed_prices_2026.json"),
    )
    parser.add_argument(
        "--minimum-records",
        type=int,
        default=MIN_EXPECTED_RECORDS,
    )
    args = parser.parse_args()

    response = requests.get(
        SOURCE_URL,
        timeout=60,
        headers={
            "User-Agent": (
                "MediX-data-sync/0.2 "
                "(public official medicine price synchronization; "
                "https://github.com/bren-wp/MediX)"
            )
        },
    )
    response.raise_for_status()

    records = parse_table(response.text)
    if len(records) < args.minimum_records:
        raise RuntimeError(
            f"Only {len(records)} HALMED price rows parsed; "
            f"minimum is {args.minimum_records}."
        )

    payload = {
        "schema_version": 1,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source": {
            "name": "HALMED / Narodne novine 64/2026",
            "url": SOURCE_URL,
            "published_date": PUBLISHED_DATE,
            "price_kind": "max_wholesale",
            "notice": (
                "Najviša dozvoljena cijena na veliko. "
                "Nije maloprodajna cijena ljekarne."
            ),
        },
        "record_count": len(records),
        "records": records,
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {len(records)} HALMED price records to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
