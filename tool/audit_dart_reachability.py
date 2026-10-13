#!/usr/bin/env python3
"""Verify every production Dart source is reachable from lib/main.dart.

This complements, but does not replace, flutter analyze and runtime tests.
Only production files under lib/ are audited; test fixtures are excluded.
"""

from __future__ import annotations

import posixpath
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
ENTRY = "lib/main.dart"
REFERENCE = re.compile(
    r'^\s*(?:import|export|part)\s+[\'"]([^\'"]+)[\'"]',
    re.MULTILINE,
)


def resolve_import(source: str, uri: str) -> str | None:
    if uri.startswith("package:medix/"):
        return posixpath.normpath("lib/" + uri[len("package:medix/"):])
    if uri.startswith("./") or uri.startswith("../"):
        return posixpath.normpath(posixpath.join(posixpath.dirname(source), uri))
    if uri.startswith("lib/"):
        return posixpath.normpath(uri)
    return None


def main() -> int:
    files = {
        path.relative_to(ROOT).as_posix(): path
        for path in LIB.rglob("*.dart")
    }
    if ENTRY not in files:
        print(f"Missing application entrypoint: {ENTRY}", file=sys.stderr)
        return 1

    graph: dict[str, set[str]] = {}
    broken: list[str] = []
    for relative, file in sorted(files.items()):
        source = file.read_text(encoding="utf-8")
        targets: set[str] = set()
        for uri in REFERENCE.findall(source):
            target = resolve_import(relative, uri)
            if target is not None:
                if target not in files:
                    broken.append(f"{relative} -> {uri} (missing {target})")
                else:
                    targets.add(target)
        graph[relative] = targets

    reachable: set[str] = set()
    pending = [ENTRY]
    while pending:
        source = pending.pop()
        if source in reachable:
            continue
        reachable.add(source)
        pending.extend(graph.get(source, set()) - reachable)

    unused = sorted(set(files) - reachable)
    print(
        f"Dart source audit: {len(files)} production files, "
        f"{len(reachable)} reachable, {len(unused)} unreachable."
    )
    for item in broken:
        print(f"BROKEN IMPORT: {item}", file=sys.stderr)
    for item in unused:
        print(f"UNREACHABLE SOURCE: {item}", file=sys.stderr)
    return 1 if broken or unused else 0


if __name__ == "__main__":
    raise SystemExit(main())
