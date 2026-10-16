#!/usr/bin/env python3
"""Build the JU revision with its code moved (config/relocation.json).

One never-executed $EA byte goes in at each insertion point, so each part of
the game moves a little further than the one before. The padding at the end
of the game code and of the music data absorbs the bytes, so the audio code
and the synthesis tables keep their addresses. The any% TAS played on this
build in MAME shows that nothing depends on the original addresses.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Any

INCBIN_PATTERN = re.compile(r'(?P<prefix>\.incbin\s+")(?P<path>[^"]+)(?P<suffix>")')


def rooted(project_root: Path, value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else project_root / path


def replace_once(text: str, old: str, new: str, meaning: str) -> str:
    count = text.count(old)
    if count != 1:
        raise ValueError(f"expected one {meaning}, found {count}")
    return text.replace(old, new, 1)


def insert_probe(text: str, insertion: dict[str, str], prefix: str = "") -> str:
    snippet = f"{prefix}relocation_probe_{insertion['id']}:\n    .byte $ea\n"
    if "before" in insertion:
        token = insertion["before"]
        return replace_once(text, token, f"{snippet}{token}", insertion["id"])
    token = insertion["after"]
    return replace_once(text, token, f"{token}\n{snippet.rstrip()}", insertion["id"])


def rebase_incbin_paths(text: str, source: Path, destination: Path) -> str:
    """Keep relative binary includes valid after copying an assembly module."""

    def replace_path(match: re.Match[str]) -> str:
        path = Path(match.group("path"))
        if path.is_absolute():
            return match.group(0)
        absolute = (source.parent / path).resolve()
        relative = Path(os.path.relpath(absolute, destination.parent)).as_posix()
        return f'{match.group("prefix")}{relative}{match.group("suffix")}'

    return INCBIN_PATTERN.sub(replace_path, text)


def prepare_source(project_root: Path, manifest: dict[str, Any]) -> Path:
    """Write the relocated main source and the two padding modules it
    overrides; return the main source."""
    source_root = rooted(project_root, manifest["generated_root"]) / "source"
    source_root.mkdir(parents=True, exist_ok=True)
    main_text = rooted(project_root, manifest["source"]).read_text(encoding="utf-8")
    main_text = f"con_revision_profile = {int(manifest['profile_id'])}\n\n{main_text}"
    first_audio = True
    for insertion in manifest["insertions"]:
        prefix = ""
        if insertion["region"] == "audio" and first_audio:
            prefix = '.segment "AUDIO"\n'
            first_audio = False
        main_text = insert_probe(main_text, insertion, prefix)
    main_path = source_root / "main.asm"
    main_path.write_text(main_text, encoding="utf-8", newline="\n")

    game = manifest["game_padding_override"]
    positioning_source = rooted(project_root, game["source"])
    positioning_path = source_root / game["include_path"]
    positioning_path.parent.mkdir(parents=True, exist_ok=True)
    positioning_text = replace_once(positioning_source.read_text(encoding="utf-8"),
                                    game["original_statement"], game["replacement_statement"],
                                    "game padding")
    positioning_path.write_text(rebase_incbin_paths(positioning_text, positioning_source, positioning_path),
                                encoding="utf-8", newline="\n")

    music = manifest["music_padding_override"]
    tail = manifest["audio_fixed_tail"]
    music_source = project_root / "src" / "audio" / "music_streams.asm"
    music_text = replace_once(music_source.read_text(encoding="utf-8"), music["original_statement"],
                              music["replacement_statement"], "music padding")
    label = f"{tail['label']}:"
    music_text = replace_once(
        music_text, label,
        f'.assert * = ${int(tail["address"], 0):04x}, error, "audio relocation budget differs"\n'
        f'.segment "FIXED_TAIL"\n\n{label}',
        "fixed synthesis-table boundary")
    music_path = source_root / "audio" / "music_streams.asm"
    music_path.parent.mkdir(parents=True, exist_ok=True)
    music_path.write_text(music_text, encoding="utf-8", newline="\n")
    return main_path


def build(project_root: Path, manifest: dict[str, Any], source: Path) -> Path:
    output_root = rooted(project_root, manifest["generated_root"])
    generated = project_root / "assets" / "generated"
    subprocess.run([
        sys.executable, str(project_root / "scripts" / "run.py"), "build.build_native",
        "--source", str(source),
        "--config", str(rooted(project_root, manifest["linker_config"])),
        "--output-dir", str(output_root),
        "--header", str(generated / "header" / "smb.hdr"),
        "--chr", str(generated / "chr" / "smb.chr"),
    ], cwd=project_root, check=True)
    return output_root / "smb.nes"


def main() -> int:
    project_root = Path(__file__).resolve().parents[2]
    parser = argparse.ArgumentParser(description=__doc__.split("\n", 1)[0])
    parser.add_argument("--manifest", type=Path, default=project_root / "config" / "relocation.json")
    args = parser.parse_args()
    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    try:
        rom = build(project_root, manifest, prepare_source(project_root, manifest))
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError) as error:
        raise SystemExit(f"[ERROR] Relocated build failed: {error}") from error
    print(f"[OK] Relocated build ({len(manifest['insertions'])} moved parts): {rom}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
