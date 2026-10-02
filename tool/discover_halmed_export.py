#!/usr/bin/env python3
"""Discover the public HALMED medicine-search form and Excel export route."""

from __future__ import annotations

import json
from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup

BASE_URL = "https://www.halmed.hr/Lijekovi/Baza-lijekova/"


def clean(value: str | None) -> str:
    return " ".join((value or "").split())


def serialize_form(form, page_url: str) -> dict:
    fields = []
    for element in form.find_all(["input", "select", "button", "textarea"]):
        fields.append(
            {
                "tag": element.name,
                "type": element.get("type"),
                "name": element.get("name"),
                "value": element.get("value"),
                "id": element.get("id"),
                "text": clean(element.get_text(" ", strip=True)),
            }
        )

    return {
        "method": (form.get("method") or "get").lower(),
        "action": urljoin(page_url, form.get("action") or page_url),
        "id": form.get("id"),
        "class": form.get("class"),
        "fields": fields,
    }


def main() -> int:
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

    response = session.get(BASE_URL, timeout=60)
    response.raise_for_status()

    soup = BeautifulSoup(response.text, "html.parser")
    forms = [serialize_form(form, response.url) for form in soup.find_all("form")]
    links = []
    for link in soup.find_all("a", href=True):
        href = urljoin(response.url, link.get("href"))
        text = clean(link.get_text(" ", strip=True))
        lower = (href + " " + text).lower()
        if any(token in lower for token in (".xls", ".xlsx", "excel", "export", "preuz")):
            links.append({"text": text, "href": href})

    print(
        json.dumps(
            {
                "status": response.status_code,
                "final_url": response.url,
                "forms": forms,
                "export_links": links,
            },
            ensure_ascii=False,
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
