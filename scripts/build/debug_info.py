#!/usr/bin/env python3
"""Retarget ld65 debug data from the bare PRG to the final iNES image."""

from __future__ import annotations

import re
from pathlib import Path


RECORD_FIELD_RE = re.compile(r'(?:^|,)([a-z]+)=("(?:[^"]|"")*"|[^,]*)')


def parse_record(line: str) -> tuple[str, dict[str, str]]:
    kind, separator, payload = line.partition("\t")
    if not separator:
        return kind, {}
    fields: dict[str, str] = {}
    for match in RECORD_FIELD_RE.finditer(payload.rstrip("\n")):
        value = match.group(2)
        if value.startswith('"') and value.endswith('"'):
            value = value[1:-1].replace('""', '"')
        fields[match.group(1)] = value
    return kind, fields


def normalize_dbg_for_ines(
    raw_path: Path,
    output_path: Path,
    linked_prg_path: Path,
    output_rom_path: Path,
    header_size: int = 16,
) -> None:
    """Retarget ld65 file offsets from the bare PRG to the final iNES image."""

    linked_names = {
        str(linked_prg_path),
        linked_prg_path.as_posix(),
        str(linked_prg_path.resolve()),
        linked_prg_path.resolve().as_posix(),
    }
    rewritten: list[str] = []
    segment_count = 0
    for line in raw_path.read_text(encoding="utf-8").splitlines(keepends=True):
        kind, fields = parse_record(line)
        if kind == "seg" and fields.get("oname") in linked_names:
            if "ooffs" not in fields:
                raise ValueError("ld65 segment record is missing ooffs")
            line = line.replace(
                f'oname="{fields["oname"]}"', f'oname="{output_rom_path}"'
            ).replace(
                f'ooffs={fields["ooffs"]}',
                f'ooffs={int(fields["ooffs"], 0) + header_size}',
            )
            segment_count += 1
        rewritten.append(line)
    if segment_count == 0:
        raise ValueError(f"No output segments for {linked_prg_path} in {raw_path}")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("".join(rewritten), encoding="utf-8", newline="\n")
