from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts"))

from build.debug_info import normalize_dbg_for_ines, parse_record  # noqa: E402


class DebugInfoTests(unittest.TestCase):
    def test_parse_record_preserves_quoted_commas_and_quotes(self) -> None:
        kind, fields = parse_record('file\tid=2,name="src/a,b""c.asm"\n')
        self.assertEqual(kind, "file")
        self.assertEqual(fields, {"id": "2", "name": 'src/a,b"c.asm'})

    def test_normalize_dbg_retargets_prg_offsets_to_ines_rom(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            raw = root / "raw.dbg"
            output = root / "game.dbg"
            prg = root / "game.prg"
            rom = root / "game.nes"
            raw.write_text(
                f'seg\tid=0,name="PRG",oname="{prg}",ooffs=0,size=32762\n'
                f'seg\tid=1,name="VECTORS",oname="{prg}",ooffs=32762,size=6\n',
                encoding="utf-8",
            )
            normalize_dbg_for_ines(raw, output, prg, rom)
            text = output.read_text(encoding="utf-8")
            self.assertIn(f'oname="{rom}",ooffs=16', text)
            self.assertIn(f'oname="{rom}",ooffs=32778', text)


if __name__ == "__main__":
    unittest.main()
