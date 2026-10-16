#!/usr/bin/env python3
"""Write program files into a Famicom Disk System side.

The side comes from the ROM (assets/manifest.json cuts it whole); every file
the source builds replaces the data of the disk files it names, so nothing of
the program comes from the ROM. `rltool assets verify` compares the result.
"""

from __future__ import annotations

import argparse
import hashlib
from dataclasses import dataclass
from pathlib import Path


class FdsError(ValueError):
    pass


@dataclass(frozen=True)
class DiskFile:
    file_id: int
    data_offset: int
    size: int


def disk_files(side: bytes) -> list[DiskFile]:
    """The files of one raw side (no fwNES header), in disk order."""
    if len(side) < 58 or side[0] != 1 or side[56] != 2:
        raise FdsError("not a raw FDS side (disk-information and file-count blocks)")
    position, files = 58, []
    for _ in range(side[57]):
        header = side[position:position + 16]
        if len(header) != 16 or header[0] != 3 or side[position + 16:position + 17] != b"\x04":
            raise FdsError(f"invalid FDS file blocks at {position:#x}")
        size = int.from_bytes(header[13:15], "little")
        data_offset = position + 17
        if data_offset + size > len(side):
            raise FdsError("truncated FDS file-data block")
        files.append(DiskFile(header[2], data_offset, size))
        position = data_offset + size
    return files


def write_files(side: bytes, contents: list[tuple[list[int], bytes]]) -> bytes:
    """The side with each content laid over the data of its disk files, in
    the order named; each content must fill its files exactly."""
    by_id: dict[int, DiskFile] = {}
    for item in disk_files(side):
        if item.file_id in by_id:
            raise FdsError(f"FDS file ID {item.file_id} is not unique")
        by_id[item.file_id] = item
    image = bytearray(side)
    written: set[int] = set()
    for file_ids, data in contents:
        position = 0
        for file_id in file_ids:
            if file_id not in by_id:
                raise FdsError(f"the side has no file {file_id}")
            if file_id in written:
                raise FdsError(f"file {file_id} is named twice")
            written.add(file_id)
            item = by_id[file_id]
            part = data[position:position + item.size]
            if len(part) != item.size:
                raise FdsError(f"{len(data)} bytes do not fill files {file_ids}")
            image[item.data_offset:item.data_offset + item.size] = part
            position += item.size
        if position != len(data):
            raise FdsError(f"{len(data)} bytes overflow files {file_ids}")
    return bytes(image)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--disk", required=True, type=Path, help="the side the files go into")
    parser.add_argument("--file", action="append", default=[], metavar="IDS=PATH",
                        help="disk file IDs (comma-separated, in order) and the built file")
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    try:
        contents = []
        for argument in args.file:
            ids, separator, path = argument.partition("=")
            if not separator or not ids or not path:
                raise FdsError(f"invalid --file {argument!r}")
            contents.append(([int(part, 0) for part in ids.split(",")], Path(path).read_bytes()))
        image = write_files(args.disk.read_bytes(), contents)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_bytes(image)
    except (OSError, ValueError) as exc:
        raise SystemExit(f"[ERROR] {exc}") from exc
    print(f"[INFO] {args.output.name}: {len(image)} bytes, SHA1 {hashlib.sha1(image).hexdigest()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
