"""Read-only decoder of the SMB1 music bank, for the relocation gate.

The relocation test decodes a song from a relocated image to prove that its
streams still end where the contract says. It needs the engine's stream
grammar and nothing of the old sound studio's editing or preview: the music
bank is read straight from the PRG through the build's labels.
"""

from __future__ import annotations

from typing import Any


MAX_CHANNEL_BYTES = 256
LENGTH_COUNTER_TABLE = (
    10, 254, 20, 2, 40, 4, 80, 6,
    160, 8, 60, 10, 14, 12, 26, 14,
    12, 16, 24, 18, 48, 20, 96, 22,
    192, 24, 72, 26, 16, 28, 32, 30,
)
NOISE_REGISTER_SETTINGS = {
    "short": (0x03, 0x18),
    "strong": (0x0C, 0x18),
    "long": (0x03, 0x58),
}
HEADER_NAMES = {
    "off_music_header_vs_star_a": "Vs. Starman A",
    "off_music_header_vs_star_b": "Vs. Starman B",
    "off_music_header_vs_star_c": "Vs. Starman C",
    "off_music_header_vs_star_d": "Vs. Starman D",
    "off_music_header_time_running_out": "Hurry Up!",
    "off_music_header_star_cloud": "Starman / Coin Heaven",
    "off_music_header_end_of_level": "Course Clear",
    "unused_music_header_residual": "Unused residual",
    "off_music_header_underground": "Underground",
    "off_music_header_silence": "Silence",
    "off_music_header_castle": "Castle",
    "off_music_header_victory": "Princess Rescued",
    "off_music_header_vs_game_over": "Vs. Game Over",
    "off_music_header_game_over": "Game Over",
    "off_music_header_water": "Underwater",
    "off_music_header_castle_clear": "Castle Clear",
    "off_music_header_ground_part_1": "Ground part 1",
    "off_music_header_ground_part_2_a": "Ground part 2A",
    "off_music_header_ground_part_2_b": "Ground part 2B",
    "off_music_header_ground_part_2_c": "Ground part 2C",
    "off_music_header_ground_part_3_a": "Ground part 3A",
    "off_music_header_ground_part_3_b": "Ground part 3B",
    "off_music_header_ground_lead_in": "Ground lead-in",
    "off_music_header_ground_part_4_a": "Ground part 4A",
    "off_music_header_ground_part_4_b": "Ground part 4B",
    "off_music_header_ground_part_4_c": "Ground part 4C",
    "off_music_header_death": "Mario Dies",
}
NOISE_HEADERS = frozenset({
    "off_music_header_star_cloud",
    "off_music_header_water",
    "off_music_header_ground_part_1",
    "off_music_header_ground_part_2_a",
    "off_music_header_ground_part_2_b",
    "off_music_header_ground_part_2_c",
    "off_music_header_ground_part_3_a",
    "off_music_header_ground_part_3_b",
    "off_music_header_ground_lead_in",
    "off_music_header_ground_part_4_a",
    "off_music_header_ground_part_4_b",
    "off_music_header_ground_part_4_c",
})


class MusicDecoder:
    """The music bank of one image: header table, streams and length table."""

    def __init__(self, labels: dict[str, int], prg: bytes, cpu_base: int) -> None:
        self.labels = labels
        self.prg = prg
        self.cpu_base = cpu_base
        self.base = labels["tbl_music_header_offsets"]
        self.end = labels["tbl_music_note_periods"]
        self.stream_addresses = sorted(
            {address for name, address in labels.items() if name.startswith("off_music_stream_")}
        )
        self.header_labels = sorted(
            (name for name in HEADER_NAMES if name in labels), key=labels.__getitem__
        )
        self.period_bytes = self._prg_bytes("tbl_music_note_periods", 0x66)
        self.lengths = list(self._prg_bytes("tbl_music_note_lengths", 48))

    def _prg_bytes(self, label: str, length: int) -> bytes:
        offset = self.labels[label] - self.cpu_base
        return self.prg[offset:offset + length]

    def byte(self, address: int) -> int:
        return self.prg[address - self.cpu_base]

    def _length(self, song: dict[str, Any], index: int) -> int:
        table_index = song["length_offset"] + song.get("length_adder", 0) + index
        if not 0 <= table_index < len(self.lengths):
            raise ValueError(f"Music length-table index {table_index} is outside the table")
        return self.lengths[table_index]

    def _period(self, note_byte: int) -> int:
        # The period table holds high-byte, low-byte pairs; a note names a pair.
        table_offset = note_byte & 0x7F
        if table_offset % 2 or table_offset + 1 >= len(self.period_bytes):
            raise ValueError(f"Music note offset ${table_offset:02X} is outside the period table")
        return (self.period_bytes[table_offset] << 8) | self.period_bytes[table_offset + 1]

    def _decode_uncompressed(
        self, song: dict[str, Any], name: str, start: int, duration_limit: int | None
    ) -> dict[str, Any]:
        address = start
        length_index = 0
        elapsed = 0
        raw = []
        while len(raw) < MAX_CHANNEL_BYTES and address < self.end:
            byte = self.byte(address)
            raw.append(byte)
            address += 1
            if byte == 0:
                break
            if byte & 0x80:
                length_index = byte & 7
                continue
            frames = self._length(song, length_index)
            if duration_limit is not None:
                frames = min(frames, max(0, duration_limit - elapsed))
            if frames <= 0:
                break
            self._period(byte)
            elapsed += frames
            if duration_limit is not None and elapsed >= duration_limit:
                break
        return {"name": name, "start": start, "end": address, "bytes": raw, "frames": elapsed}

    def _decode_compressed(
        self, song: dict[str, Any], name: str, start: int, duration_limit: int
    ) -> dict[str, Any]:
        address = start
        elapsed = 0
        raw = []
        while len(raw) < MAX_CHANNEL_BYTES and address < self.end and elapsed < duration_limit:
            byte = self.byte(address)
            raw.append(byte)
            address += 1
            if byte == 0:
                if name == "noise":
                    break
                continue
            length_index = ((byte & 1) << 2) | (byte >> 6)
            frames = min(self._length(song, length_index), duration_limit - elapsed)
            if name != "noise":
                self._period(byte & 0x3E)
            elapsed += frames
        return {"name": name, "start": start, "end": address, "bytes": raw, "frames": elapsed}

    def song(self, label: str, length_adder: int = 0) -> dict[str, Any]:
        """Decode one song's channels from its header, as the engine reads them."""
        address = self.labels[label]
        following = [self.labels[item] for item in self.header_labels if self.labels[item] > address]
        following.extend(value for value in self.stream_addresses if value > address)
        header = [self.byte(pointer) for pointer in range(address, min(following))]
        if len(header) not in {4, 5, 6}:
            raise ValueError(f"{label} has unsupported {len(header)}-byte header")
        data_address = header[1] | (header[2] << 8)
        song = {"label": label, "name": HEADER_NAMES[label], "address": address,
                "length_offset": header[0], "length_adder": length_adder,
                "data_address": data_address}
        channels = [self._decode_uncompressed(song, "square2", data_address, None)]
        duration = channels[0]["frames"]
        if label == "off_music_header_underground":
            channels.append(self._decode_uncompressed(song, "triangle", data_address, duration))
        elif header[3]:
            channels.append(self._decode_uncompressed(song, "triangle", data_address + header[3], duration))
        if len(header) >= 5 and header[4]:
            channels.append(self._decode_compressed(song, "square1", data_address + header[4], duration))
        if len(header) == 6 and header[5] and label in NOISE_HEADERS:
            channels.append(self._decode_compressed(song, "noise", data_address + header[5], duration))
        song["channels"] = channels
        song["frames"] = duration
        return song
