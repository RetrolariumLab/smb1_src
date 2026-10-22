# Data formats

The game's content is not in this repository: each table below has a label in
the source and takes its bytes from your ROM or disk (`.incbin` of an asset
`make split` cuts, see `assets/manifest.json`). This page gives the formats as
the JU engine reads them; [revisions](revisions.md) says where other revisions
differ. Retrolarium Kit's codecs (`smb.world.v1`, `smb.levels.v1`,
`smb.apu-music.v1`) read and write the same formats.

## Worlds and areas

`tbl_world_area_pointer_offsets` gives, for each world, the index of its first
course in `tbl_area_pointers`; the area number within the world is added to
it. A world has five, four or five courses (counting the intermediate areas
such as pipe intros): 5, 5, 4, 5, 4, 4, 5 and 4 for worlds 1-8.

An area pointer byte:

| Bits | Meaning |
| --- | --- |
| 7 | kept, not read by the lookup |
| 6-5 | area type: 0 water, 1 ground, 2 underground, 3 castle |
| 4-0 | the area's index within its type |

`sub_get_area_data_addresses` adds the index to the type's base in
`tbl_area_object_data_offsets_by_area_type` and
`tbl_enemy_data_offsets_by_area_type`, and reads the stream addresses from
`tbl_area_object_data_ptr_lo`/`_hi` and `tbl_enemy_data_ptr_lo`/`_hi`.

## Area header

Each area-object stream starts with a two-byte header.

| Byte | Bits | Meaning |
| --- | --- | --- |
| 0 | 7-6 | game timer setting (`ram_game_timer_setting`) |
| 0 | 5-3 | player entrance (`ram_player_entrance_ctrl`); a halfway restart forces 2 |
| 0 | 2-0 | 0-3 foreground scenery, 4-7 background colour control |
| 1 | 7-6 | area style; 3 means cloud override instead |
| 1 | 5-4 | background scenery |
| 1 | 3-0 | terrain control |

## Area objects

After the header come two-byte objects and the terminator `$FD`. In both
bytes:

| Byte | Bits | Meaning |
| --- | --- | --- |
| 0 | 7-4 | column within the page |
| 0 | 3-0 | row; 12-15 are special rows |
| 1 | 7 | page flag: this object starts the next page |
| 1 | 6-0 | object: see below |

- Rows 0-11: if bits 6-4 of byte 1 are zero, bits 3-0 select a small object
  (one tile); otherwise bits 6-4 select a large object and bits 3-0 its length.
  Large object 7 is a vertical pipe, and bit 3 then makes it a warp pipe.
- Row 12 and row 15: bits 6-4 of byte 1 select one of the row's special
  objects, and bits 3-0 give their length where the object has one.
- Row 13: bit 6 clear makes it a page skip to the page in bits 4-0; bit 6 set
  selects a special object by bits 5-0, where `$4B` (with bit 6) is the loop
  command.
- Row 14: an alternate scenery and terrain change.

`tbl_area_object_loopback_offsets` and the loop tables in
`game/level/parser.asm` give the castle maze loops.

## Enemy objects

Enemy streams use two-byte objects (three for row 14) and the terminator
`$FF`.

| Byte | Bits | Meaning |
| --- | --- | --- |
| 0 | 7-4 | column within the page |
| 0 | 3-0 | row (0-13), or 14 and 15 below |
| 1 | 7 | page flag |
| 1 | 6 | hard mode only: skipped unless the secondary hard mode is on (world 5-3 on, or the second quest) |
| 1 | 5-0 | enemy id; `$37-$3E` are groups of Goombas and Koopas |

- Row 14 is a three-byte area transition: byte 1 is the area pointer of the
  destination, byte 2 bits 7-5 the world it applies in and bits 4-0 the
  entrance page.
- Row 15 is a page skip: byte 1 bits 5-0 give the page.

In the primary hard mode a Goomba becomes a Buzzy Beetle.

## Music

`tbl_music_header_offsets` holds the song headers, which the event and area
music queues select:

| Byte | Meaning |
| --- | --- |
| 0 | offset of the song's eight lengths in `tbl_music_note_lengths` |
| 1-2 | address of the song's data |
| 3 | triangle offset into that data |
| 4 | square 1 offset (0: no square 1) |
| 5 | noise offset |

Square 2 starts at offset 0. Several songs and channels share data.

- **Square 2**: `$00` ends the song (area music and the victory tune loop),
  `$01-$7F` is a note (`tbl_music_note_periods` index), and `$80-$FF` sets the
  length (bits 2-0) and is followed by a note.
- **Triangle**: like square 2, but `$00` only silences the channel.
- **Square 1**: `$00` loads the death music's register values and reads on;
  any other byte packs a note in bits 5-1 and a length index in bits 0, 7 and
  6 (from high to low).
- **Noise**: the same packing, with the beat in bits 5-1 (`$30` long, `$20`
  strong, bit 4 short, otherwise silent); `$00` loops back to the noise start.

The lengths are read through byte 0 of the header, plus 8 once the
time-running-out tune has played, which speeds the area music up. `tbl_music_note_periods` holds the square and triangle periods.

## Player physics

`game/player/physics.asm` keeps the player's tuning tables (jump and fall
gravity, initial vertical speeds and their fractions, maximum speeds and
friction); [player movement](player_movement.md) describes how they combine.
