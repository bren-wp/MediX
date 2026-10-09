#!/usr/bin/env python3
"""Validate MediX official catalogs and write a technical quality report."""

from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path

ATC_TOKEN_RE = re.compile(
    r"^(?:[A-Z]|[A-Z]\d{2}|[A-Z]\d{2}[A-Z]|"
    r"[A-Z]\d{2}[A-Z]{2}|[A-Z]\d{2}[A-Z]{2}\d{2})$"
)
LEGAL_ENTITY_RE = re.compile(
    r"(?:^|\s)(?:d\.?\s*o\.?\s*o\.?|d\.?\s*d\.?|j\.?\s*d\.?\s*o\.?\s*o\.?|"
    r"obrt|ustanova|limited|ltd\.?|gmbh|s\.?a\.?|b\.?v\.?)(?:\s|$)",
    re.IGNORECASE,
)
TECHNICAL_NAMES = {
    "naziv",
    "naziv lijeka",
    "proizvođač",
    "nositelj odobrenja",
    "nije navedeno",
    "nepoznato",
}
SUSPICIOUS_NAME_RE = re.compile(
    r"^(?:[-–—./\\]+|\d+)$|(?:https?://|www\.|@)",
    re.IGNORECASE,
)


def load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def clean(value: object | None) -> str:
    return re.sub(r"\s+", " ", "" if value is None else str(value)).strip()


def norm(value: object | None) -> str:
    return clean(value).casefold()


def atc_tokens(value: object | None) -> list[str]:
    text = clean(value).upper()
    if text in {"", "-"}:
        return []
    return [
        part.strip()
        for part in re.split(r"[;,]", text)
        if part.strip()
    ]


def is_valid_atc(value: object | None) -> bool:
    return all(
        ATC_TOKEN_RE.fullmatch(token) is not None
        for token in atc_tokens(value)
    )


def validate_halmed(data: dict, minimum: int) -> dict:
    source = data.get("source")
    if not isinstance(source, dict):
        raise RuntimeError("HALMED source metadata is missing.")
    if clean(source.get("medicine_name_field")) != "Naziv":
        raise RuntimeError(
            "HALMED medicine-name provenance is not explicitly bound to the Naziv column."
        )

    records = data.get("records")
    if not isinstance(records, list):
        raise RuntimeError("HALMED records is not a list.")
    if len(records) < minimum:
        raise RuntimeError(
            f"HALMED record count {len(records)} is below minimum {minimum}."
        )

    ids = [clean(row.get("id")) for row in records]
    if any(not value for value in ids):
        raise RuntimeError("HALMED contains an empty ID.")
    duplicate_ids = [value for value, count in Counter(ids).items() if count > 1]
    if duplicate_ids:
        raise RuntimeError(f"HALMED duplicate IDs: {duplicate_ids[:10]}")

    canonical = [
        (norm(row.get("authorization_number")), norm(row.get("name")))
        for row in records
    ]
    duplicate_rows = [
        value for value, count in Counter(canonical).items() if count > 1
    ]
    if duplicate_rows:
        raise RuntimeError(
            f"HALMED duplicate medicine identities: {duplicate_rows[:10]}"
        )

    invalid_names: list[str] = []
    invalid_atc: list[str] = []
    duplicate_placeholders: list[str] = []

    for row in records:
        name = clean(row.get("name"))
        holder = norm(row.get("holder"))
        manufacturer = norm(row.get("manufacturer"))
        normalized_name = name.casefold()

        if (
            not name
            or normalized_name in TECHNICAL_NAMES
            or (holder and normalized_name == holder)
            or (manufacturer and normalized_name == manufacturer)
            or LEGAL_ENTITY_RE.search(name)
            or SUSPICIOUS_NAME_RE.search(name)
        ):
            invalid_names.append(name)

        atc = clean(row.get("atc_code")).upper()
        if not is_valid_atc(atc):
            invalid_atc.append(atc)

        strength = norm(row.get("strength"))
        form = norm(row.get("form"))
        if strength == "doza" and form == "doza":
            duplicate_placeholders.append(name)

    if invalid_names:
        raise RuntimeError(
            "Invalid HALMED medicine names: "
            + ", ".join(invalid_names[:10])
        )
    if invalid_atc:
        raise RuntimeError(
            "Invalid HALMED ATC codes: "
            + ", ".join(sorted(set(invalid_atc))[:10])
        )
    if duplicate_placeholders:
        raise RuntimeError(
            "Invalid 'doza · doza' source fields: "
            + ", ".join(duplicate_placeholders[:10])
        )

    names = {norm(row.get("name")) for row in records}
    if "a1 d.o.o." in names:
        raise RuntimeError("Regression: A1 d.o.o. is present as a medicine.")

    rx = 0
    otc = 0
    unknown = 0
    market = Counter()
    shortage = Counter()
    for row in records:
        status = norm(row.get("rx_status"))
        if "bez recepta" in status:
            otc += 1
        elif "recept" in status:
            rx += 1
        else:
            unknown += 1

        market_status = norm(row.get("market_status"))
        if "privremeni prekid" in market_status:
            market["temporary_interruption"] += 1
        elif "nije stavljeno u promet" in market_status:
            market["not_marketed"] += 1
        elif "stavljeno u promet" in market_status:
            market["marketed"] += 1
        else:
            market["unknown"] += 1

        shortage_status = norm(row.get("shortage_status"))
        if "nema nestašice" in shortage_status:
            shortage["none_reported"] += 1
        elif "nestašic" in shortage_status:
            shortage["reported"] += 1
        else:
            shortage["unknown"] += 1

    quality = data.get("quality") if isinstance(data.get("quality"), dict) else {}
    rejected_reasons = quality.get("rejected_reasons")
    if not isinstance(rejected_reasons, dict):
        rejected_reasons = {}

    return {
        "total": len(records),
        "unique_names": len({norm(row.get("name")) for row in records if clean(row.get("name"))}),
        "active_ingredients": len({
            norm(row.get("active_ingredient"))
            for row in records
            if clean(row.get("active_ingredient"))
        }),
        "atc_codes": len({
            token
            for row in records
            for token in atc_tokens(row.get("atc_code"))
        }),
        "rx": rx,
        "otc": otc,
        "unknown_dispensing": unknown,
        "marketed": market["marketed"],
        "not_marketed": market["not_marketed"],
        "temporary_interruption": market["temporary_interruption"],
        "unknown_market_status": market["unknown"],
        "shortage_reported": shortage["reported"],
        "shortage_none_reported": shortage["none_reported"],
        "unknown_shortage_status": shortage["unknown"],
        "missing_atc": sum(
            1
            for row in records
            if not atc_tokens(row.get("atc_code"))
        ),
        "missing_package": sum(1 for row in records if not clean(row.get("package"))),
        "rejected_records": int(quality.get("rejected_records", 0) or 0),
        "rejected_reasons": rejected_reasons,
    }


def validate_secondary(data: dict, label: str, minimum: int) -> int:
    records = data.get("records")
    if not isinstance(records, list):
        raise RuntimeError(f"{label} records is not a list.")
    if len(records) < minimum:
        raise RuntimeError(
            f"{label} record count {len(records)} is below minimum {minimum}."
        )
    return len(records)


def write_report(
    path: Path,
    halmed: dict,
    hzzo_count: int,
    price_count: int,
    stats: dict,
) -> None:
    generated = clean(halmed.get("generated_at")) or "nije navedeno"
    rejected = stats["rejected_reasons"]
    rejected_lines = (
        "\n".join(
            f"- `{reason}`: {count}"
            for reason, count in sorted(rejected.items())
        )
        if rejected
        else "- Nema evidentiranih odbačenih zapisa."
    )

    report = f"""# MediX Data Quality Report

Tehnički izvještaj generiran iz službenih podatkovnih sinkronizacija.

- HALMED generirano: {generated}
- Prihvaćeni HALMED zapisi: {stats["total"]}
- Jedinstveni nazivi: {stats["unique_names"]}
- Jedinstvene djelatne tvari: {stats["active_ingredients"]}
- Jedinstvene ATK šifre: {stats["atc_codes"]}
- Na recept: {stats["rx"]}
- Bez recepta (OTC): {stats["otc"]}
- Bez poznatog režima izdavanja: {stats["unknown_dispensing"]}
- Stavljeno u promet: {stats["marketed"]}
- Nije stavljeno u promet: {stats["not_marketed"]}
- Privremeni prekid opskrbe: {stats["temporary_interruption"]}
- Bez poznatog tržišnog statusa: {stats["unknown_market_status"]}
- Prijavljena nestašica: {stats["shortage_reported"]}
- Bez evidentirane nestašice: {stats["shortage_none_reported"]}
- Bez poznatog statusa nestašice: {stats["unknown_shortage_status"]}
- Bez ATK: {stats["missing_atc"]}
- Bez pakiranja: {stats["missing_package"]}
- Odbačeni HALMED zapisi: {stats["rejected_records"]}
- HZZO enrichment zapisi: {hzzo_count}
- Cjenovni zapisi: {price_count}

## Razlozi odbacivanja

{rejected_lines}

## Aktivne zaštite

- naziv lijeka mora postojati
- broj odobrenja mora postojati
- naziv ne smije biti jednak nositelju ili proizvođaču
- pravna osoba ne smije biti identitet lijeka
- tehnički/header placeholderi nisu dopušteni kao naziv
- URL/e-mail, brojčani i interpunkcijski placeholderi nisu dopušteni kao naziv
- izvor naziva mora biti eksplicitno vezan uz službeni HALMED stupac `Naziv`
- ATK je validiran kada je naveden
- duplicate ID i duplicate identitet zaustavljaju validaciju
- regresijski zapis `A1 d.o.o.` ne smije postojati
- izvorni `doza · doza` placeholder zaustavlja validaciju
- broj HALMED zapisa ne smije pasti ispod sigurnosnog minimuma
- HZZO i cijene ostaju enrichment slojevi

Ovaj izvještaj ne tvrdi potpunu pokrivenost svih mogućih tržišnih i
centralizirano odobrenih zapisa izvan onoga što je dohvaćeno javnim HALMED
workflowom. README/UI ne smiju koristiti tvrdnju „svi lijekovi” bez zasebne
potvrde pokrivenosti.
"""
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(report, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--halmed",
        type=Path,
        default=Path("assets/data/halmed_catalog.json"),
    )
    parser.add_argument(
        "--hzzo",
        type=Path,
        default=Path("assets/data/medications_official.json"),
    )
    parser.add_argument(
        "--prices",
        type=Path,
        default=Path("assets/data/halmed_prices_2026.json"),
    )
    parser.add_argument(
        "--report",
        type=Path,
        default=Path("docs/DATA_QUALITY_REPORT.md"),
    )
    parser.add_argument("--halmed-minimum", type=int, default=4000)
    parser.add_argument("--hzzo-minimum", type=int, default=500)
    parser.add_argument("--price-minimum", type=int, default=1000)
    args = parser.parse_args()

    halmed = load(args.halmed)
    hzzo = load(args.hzzo)
    prices = load(args.prices)

    stats = validate_halmed(halmed, args.halmed_minimum)
    hzzo_count = validate_secondary(hzzo, "HZZO", args.hzzo_minimum)
    price_count = validate_secondary(
        prices,
        "HALMED prices",
        args.price_minimum,
    )
    write_report(args.report, halmed, hzzo_count, price_count, stats)

    print(
        "Validated catalogs: "
        f"HALMED={stats['total']}, "
        f"HZZO={hzzo_count}, prices={price_count}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
