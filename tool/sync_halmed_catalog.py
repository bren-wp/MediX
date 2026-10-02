#!/usr/bin/env python3
"""Synchronize the complete public HALMED human-medicine registry.

HALMED's public medicine database is the identity source for MediX. Other
catalogs may enrich these records, but may not create a medicine on their own.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import json
import re
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup
from openpyxl import load_workbook

BASE_URL = "https://www.halmed.hr/Lijekovi/Baza-lijekova/"
MIN_EXPECTED_RECORDS = 4000

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
    r"(\d+(?:[.,]\d+)?\s*(?:mg|g|µg|mcg|mikrograma|ml|mmol|IU|i\.j\.|%|"
    r"jedinica)(?:\s*/\s*\d+(?:[.,]\d+)?\s*(?:ml|g))?)",
    re.IGNORECASE,
)

REQUIRED_HEADERS = {
    "Naziv",
    "Broj odobrenja",
    "Djelatna tvar",
    "Farmaceutski oblik",
    "Nositelj odobrenja",
    "Način izdavanja",
    "ATK",
}


def clean(value: object | None) -> str:
    return re.sub(r"\s+", " ", "" if value is None else str(value)).strip()


def stable_id(approval: str, name: str) -> str:
    basis = f"{approval}|{name}".encode("utf-8")
    return "halmed-" + hashlib.sha1(basis).hexdigest()[:24]


def category_for(atc: str) -> str:
    first = clean(atc)[:1].upper()
    return ATC_CATEGORIES.get(first, "Ostali lijekovi")


def derive_strength(name: str, composition: str) -> str:
    for value in (name, composition):
        match = STRENGTH_RE.search(value or "")
        if match:
            return clean(match.group(1))
    return "nije navedeno"


def find_export_url(html: str, page_url: str) -> str:
    soup = BeautifulSoup(html, "html.parser")
    for link in soup.find_all("a", href=True):
        href = urljoin(page_url, link.get("href"))
        text = clean(link.get_text(" ", strip=True)).lower()
        if href.lower().endswith(".xlsx") or (
            "spremi rezultate" in text and "xlsx" in text
        ):
            return href
    raise RuntimeError("HALMED XLSX export link was not discovered.")


def medicine_links(html: str, page_url: str) -> dict[str, str]:
    soup = BeautifulSoup(html, "html.parser")
    result: dict[str, str] = {}
    prefix = "/Lijekovi/Baza-lijekova/"
    for link in soup.find_all("a", href=True):
        href = urljoin(page_url, link.get("href"))
        if prefix not in href or href.rstrip("/") == BASE_URL.rstrip("/"):
            continue
        title = clean(link.get_text(" ", strip=True))
        if title:
            result.setdefault(title.casefold(), href)
    return result


def find_header_row(sheet) -> tuple[int, list[str]]:
    for row_number, row in enumerate(
        sheet.iter_rows(min_row=1, max_row=40, values_only=True),
        start=1,
    ):
        headers = [clean(value) for value in row]
        if REQUIRED_HEADERS.issubset(set(headers)):
            return row_number, headers
    raise RuntimeError("HALMED XLSX header row was not recognized.")


def parse_workbook(content: bytes, detail_links: dict[str, str]) -> list[dict]:
    workbook = load_workbook(
        io.BytesIO(content),
        read_only=True,
        data_only=True,
    )
    sheet = workbook[workbook.sheetnames[0]]
    header_row, headers = find_header_row(sheet)
    header_index = {
        header: index
        for index, header in enumerate(headers)
        if header
    }

    def value(row: tuple, header: str) -> str:
        index = header_index.get(header)
        if index is None or index >= len(row):
            return ""
        return clean(row[index])

    records: list[dict] = []
    seen_ids: set[str] = set()

    for row in sheet.iter_rows(
        min_row=header_row + 1,
        values_only=True,
    ):
        name = value(row, "Naziv")
        approval = value(row, "Broj odobrenja")
        active = value(row, "Djelatna tvar")
        revoked = value(row, "Datum ukidanja rješenja")

        if not name or not approval:
            continue
        if revoked:
            # Revoked marketing authorisations are not current medicines.
            continue

        record_id = stable_id(approval, name)
        if record_id in seen_ids:
            continue
        seen_ids.add(record_id)

        atc = value(row, "ATK")
        composition = value(row, "Sastav")
        dispensing = value(row, "Način izdavanja")
        market_status = value(row, "Status lijeka na tržištu")
        shortage = value(row, "Status nestašice")
        package = value(row, "Pakiranje")

        records.append(
            {
                "id": record_id,
                "name": name,
                "previous_name": value(row, "Raniji naziv"),
                "authorization_number": approval,
                "active_ingredient": active,
                "composition": composition,
                "form": value(row, "Farmaceutski oblik") or "lijek",
                "strength": derive_strength(name, composition),
                "package": package,
                "manufacturer": value(row, "Proizvođač"),
                "holder": value(row, "Nositelj odobrenja"),
                "decision_date": value(row, "Datum rješenja"),
                "authorization_expiry": value(row, "Rok rješenja"),
                "class": value(row, "Klasa"),
                "urbroj": value(row, "Urbroj"),
                "rx_status": dispensing,
                "prescribing_mode": value(row, "Način propisivanja"),
                "dispensing_place": value(row, "Mjesto izdavanja"),
                "advertising": value(
                    row,
                    "Način oglašavanja prema stanovništvu",
                ),
                "atc_code": atc,
                "category": category_for(atc),
                "market_status": market_status,
                "shortage_status": shortage,
                "official_record_url": detail_links.get(name.casefold()),
            }
        )

    records.sort(
        key=lambda item: (
            item["name"].casefold(),
            item["authorization_number"],
        )
    )
    return records


def validate(records: list[dict], minimum: int) -> None:
    if len(records) < minimum:
        raise RuntimeError(
            f"Only {len(records)} current HALMED medicines parsed; "
            f"minimum is {minimum}."
        )

    forbidden_names = {
        "a1 d.o.o.",
        "a.g.r.",
        "m.b.s.",
        "namirnice bez glutena",
    }
    offenders = [
        record["name"]
        for record in records
        if record["name"].casefold() in forbidden_names
    ]
    if offenders:
        raise RuntimeError(
            "Non-medicine/company names leaked into HALMED catalog: "
            + ", ".join(sorted(set(offenders)))
        )

    missing_names = [
        record["authorization_number"]
        for record in records
        if not clean(record.get("name"))
    ]
    if missing_names:
        raise RuntimeError(
            f"{len(missing_names)} records are missing medicine names."
        )

    company_only = [
        record["name"]
        for record in records
        if record["name"].casefold()
        == clean(record.get("holder")).casefold()
        and clean(record.get("holder"))
    ]
    if company_only:
        raise RuntimeError(
            "Holder was mapped as medicine name: "
            + ", ".join(company_only[:10])
        )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("assets/data/halmed_catalog.json"),
    )
    parser.add_argument(
        "--minimum-records",
        type=int,
        default=MIN_EXPECTED_RECORDS,
    )
    args = parser.parse_args()

    session = requests.Session()
    session.headers.update(
        {
            "User-Agent": (
                "MediX-catalog-sync/0.3.1 "
                "(public HALMED human-medicine catalog synchronization; "
                "https://github.com/bren-wp/MediX)"
            )
        }
    )

    landing = session.get(BASE_URL, timeout=60)
    landing.raise_for_status()

    search = session.post(
        BASE_URL,
        data={"trazi_baza": "OK"},
        timeout=180,
        allow_redirects=True,
    )
    search.raise_for_status()

    export_url = find_export_url(search.text, search.url)
    links = medicine_links(search.text, search.url)

    export = session.get(export_url, timeout=180)
    export.raise_for_status()

    records = parse_workbook(export.content, links)
    validate(records, args.minimum_records)

    payload = {
        "schema_version": 2,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source": {
            "name": "HALMED Baza lijekova",
            "url": BASE_URL,
            "scope": "current_authorized_human_medicines",
        },
        "record_count": len(records),
        "records": records,
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(
        f"Wrote {len(records)} current HALMED human medicines "
        f"to {args.output}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
