#!/usr/bin/env python3
"""Synchronize the public Croatian MKB-10 code table into MediX."""

from __future__ import annotations

import argparse
import csv
import io
import json
import re
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup

ROOT = "https://mkb.hzjz.hr/"
MIN_EXPECTED_RECORDS = 1000
CODE_RE = re.compile(r"^[A-Z][0-9]{2}(?:\.?[0-9A-Z]{1,2})?$")


def clean(value: str) -> str:
    return re.sub(r"\s+", " ", value or "").strip()


def find_csv_url(html: str) -> str:
    soup = BeautifulSoup(html, "html.parser")
    candidates: list[str] = []
    for link in soup.find_all("a", href=True):
        href = link.get("href") or ""
        text = clean(link.get_text(" ", strip=True)).lower()
        if ".csv" in href.lower() or "csv" in text:
            candidates.append(urljoin(ROOT, href))
    if not candidates:
        raise RuntimeError("MKB-10 CSV download link was not discovered.")
    return candidates[0]


def decode_bytes(content: bytes) -> str:
    for encoding in ("utf-8-sig", "utf-8", "cp1250", "latin-1"):
        try:
            return content.decode(encoding)
        except UnicodeDecodeError:
            continue
    raise RuntimeError("Unable to decode MKB-10 CSV.")


def parse_records(text: str) -> list[dict]:
    sample = text[:10000]
    delimiter = ";"
    try:
        delimiter = csv.Sniffer().sniff(sample, delimiters=";,\t,").delimiter
    except csv.Error:
        pass

    records: dict[str, dict] = {}
    reader = csv.reader(io.StringIO(text), delimiter=delimiter)
    for row in reader:
        cells = [clean(cell) for cell in row]
        if not any(cells):
            continue

        code_index = None
        code = ""
        for index, cell in enumerate(cells):
            normalized = cell.upper().replace(" ", "")
            if CODE_RE.match(normalized):
                code_index = index
                code = normalized
                break

        if code_index is None:
            continue

        description = ""
        for cell in cells[code_index + 1 :]:
            if cell and cell != code:
                description = cell
                break

        if not description:
            for cell in cells:
                if cell and cell != code:
                    description = cell
                    break

        if not description:
            continue

        records[code] = {
            "code": code,
            "title": description,
            "chapter": code[0],
        }

    return sorted(records.values(), key=lambda item: item["code"])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("assets/data/icd10.json"),
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
                "MediX-classification-sync/0.3 "
                "(https://github.com/bren-wp/MediX)"
            )
        }
    )

    landing = session.get(ROOT, timeout=60)
    landing.raise_for_status()
    csv_url = find_csv_url(landing.text)

    response = session.get(csv_url, timeout=60)
    response.raise_for_status()

    records = parse_records(decode_bytes(response.content))
    if len(records) < args.minimum_records:
        raise RuntimeError(
            f"Only {len(records)} MKB-10 records parsed; "
            f"minimum is {args.minimum_records}."
        )

    payload = {
        "schema_version": 1,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "record_count": len(records),
        "records": records,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {len(records)} MKB-10 records to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
