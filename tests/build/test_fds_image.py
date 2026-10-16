from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts"))

from build.fds_image import FdsError, disk_files, write_files  # noqa: E402


def disk_file(file_id: int, data: bytes) -> bytes:
    header = bytes((3, 0, file_id)) + b"FILE    " + (0x6000).to_bytes(2, "little")
    return header + len(data).to_bytes(2, "little") + b"\x00\x04" + data


def side(*files: bytes) -> bytes:
    return b"\x01" + bytes(55) + bytes((2, len(files))) + b"".join(files) + bytes(32)


class FdsImageTests(unittest.TestCase):
    def setUp(self) -> None:
        self.side = side(disk_file(0, b"KYODAKU"), disk_file(3, b"aaaa"), disk_file(4, b"bb"))

    def test_the_files_are_found_in_disk_order(self) -> None:
        self.assertEqual([(item.file_id, item.size) for item in disk_files(self.side)],
                         [(0, 7), (3, 4), (4, 2)])

    def test_a_program_fills_its_files_in_the_order_named(self) -> None:
        image = write_files(self.side, [([3, 4], b"123456")])
        self.assertEqual(image, side(disk_file(0, b"KYODAKU"), disk_file(3, b"1234"), disk_file(4, b"56")))

    def test_a_program_must_fill_its_files_exactly(self) -> None:
        for data in (b"12345", b"1234567"):
            with self.assertRaises(FdsError):
                write_files(self.side, [([3, 4], data)])
        with self.assertRaises(FdsError):
            write_files(self.side, [([9], b"1")])


if __name__ == "__main__":
    unittest.main()
