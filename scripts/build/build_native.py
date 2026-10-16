#!/usr/bin/env python3
"""Assemble and link a ca65 source into a PRG and, given the header and the
CHR, the iNES image (`rltool assets verify` compares it with the ROM)."""

from __future__ import annotations

import argparse
import hashlib
import os
import shutil
import subprocess
import sys
from pathlib import Path

from build.kit_tools import kit_tool_path
from build.debug_info import normalize_dbg_for_ines


def fail(message: str) -> None:
    print(f"[ERROR] {message}", file=sys.stderr)
    raise SystemExit(1)


def sha1(data: bytes) -> str:
    return hashlib.sha1(data).hexdigest()


def rooted(project_root: Path, value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else project_root / path


def resolve_tool(name: str, project_root: Path) -> Path:
    """The cc65 program Retrolarium Kit ships, else one on PATH."""
    try:
        return kit_tool_path(f"nes/{name}")
    except (OSError, ValueError) as exc:
        found = shutil.which(name)
        if found:
            return Path(found)
        fail(f"{name} not found (Retrolarium Kit: {exc}; not on PATH)")
    raise AssertionError


def run_tool(tool: Path, arguments: list[str], cwd: Path) -> None:
    command = [str(tool), *arguments]
    if os.name != "nt" and tool.suffix.lower() == ".exe":
        wine = shutil.which("wine")
        if not wine:
            fail(f"wine not found in PATH (needed to run {tool.name})")
        command.insert(0, wine)
    print("[RUN]", " ".join(command))
    result = subprocess.run(command, cwd=cwd, check=False)
    if result.returncode:
        fail(f"command failed with exit code {result.returncode}")


def require_file(path: Path, description: str) -> bytes:
    if not path.is_file():
        fail(f"{description} not found: {path}")
    return path.read_bytes()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", default="src/main.asm")
    parser.add_argument("--config", default="config/linker/nrom256_prg_only.cfg")
    parser.add_argument("--output-dir", default="build/native",
                        help="where <name>.o, .prg, .lbl, .map, .dbg (and .nes) go")
    parser.add_argument("--name", default="smb")
    parser.add_argument("--bin-include-dir", action="append", default=[])
    parser.add_argument("--header", help="the iNES header; with --chr, write <name>.nes")
    parser.add_argument("--chr", help="the CHR that follows the PRG")
    parser.add_argument("--extra", help="what follows the CHR (the PlayChoice-10 instruction ROM)")
    args = parser.parse_args()

    project_root = Path(__file__).resolve().parents[2]
    source = rooted(project_root, args.source)
    config = rooted(project_root, args.config)
    output_dir = rooted(project_root, args.output_dir)
    for path, description in ((source, "source"), (config, "linker config")):
        if not path.is_file():
            fail(f"{description} not found: {path}")
    if bool(args.header) != bool(args.chr):
        fail("an iNES image needs both --header and --chr")
    output_dir.mkdir(parents=True, exist_ok=True)
    stem = output_dir / args.name
    object_path, prg_path = stem.with_suffix(".o"), stem.with_suffix(".prg")
    debug_path = stem.with_suffix(".dbg")
    raw_debug_path = stem.with_suffix(".ld65.dbg")

    assembler_arguments = [str(source), "-g", "-I", str(source.parent), "-I", str(project_root / "src")]
    for directory in args.bin_include_dir:
        assembler_arguments.extend(("--bin-include-dir", str(rooted(project_root, directory))))
    assembler_arguments.extend(("-o", str(object_path)))
    run_tool(resolve_tool("ca65", project_root), assembler_arguments, project_root)
    run_tool(resolve_tool("ld65", project_root), [
        "-C", str(config), str(object_path), "-o", str(prg_path),
        "-Ln", str(stem.with_suffix(".lbl")), "--mapfile", str(stem.with_suffix(".map")), "-vm",
        "--dbgfile", str(raw_debug_path),
    ], output_dir)
    prg = require_file(prg_path, "linked PRG")
    print(f"[INFO] PRG: {len(prg)} bytes, SHA1 {sha1(prg)}")
    if not args.header:
        raw_debug_path.replace(debug_path)
        return 0

    rom_path = stem.with_suffix(".nes")
    # The debug file names the image, at the PRG's offsets after the header.
    normalize_dbg_for_ines(raw_debug_path, debug_path, prg_path, rom_path)
    raw_debug_path.unlink()
    image = require_file(rooted(project_root, args.header), "header asset") + prg \
        + require_file(rooted(project_root, args.chr), "CHR asset")
    if args.extra:
        image += require_file(rooted(project_root, args.extra), "asset after the CHR")
    rom_path.write_bytes(image)
    print(f"[INFO] {rom_path.name}: {len(image)} bytes, SHA1 {sha1(image)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
