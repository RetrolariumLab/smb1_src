# Editing in Retrolarium

Super Mario Bros.'s data is edited in Retrolarium Studio, not by tools in this
repository. Open `super_mario_bros.rlj` at the repository root in the studio. It
asks which revision to edit, takes that revision's ROM (copied next to
`super_mario_bros.rlj` and never committed) and keeps the edits in
`hack/<revision>/`. Builds go to `.retrolarium/`. Neither folder is tracked;
delete `hack/<revision>/` to start over from the original.

Until Source Reconstruction 3.0 the repository carried four Tkinter studios
(World, Level, Graphics and Sound) with their models and a workspace composer.
They are in history at the `source-reconstruction-2.2` tag and earlier; the
studio and the kit replaced each of them.

## Revisions

| Revision      | ROM                                                                  | What it is                             |
| ------------- | -------------------------------------------------------------------- | -------------------------------------- |
| `ju`          | `Super Mario Bros. (JU) [!].nes`                                     | The Japan/USA cartridge.               |
| `pal`         | `Super Mario Bros. (E) (REV0) [!p].nes`                              | The European cartridge.                |
| `pc10`        | `Super Mario Bros. (PC10).nes`                                       | PlayChoice-10, with its extra payload. |
| `vs_smb`      | `VS. Super Mario Bros. (VS).nes`                                     | Vs. Super Mario Bros. (arcade).        |
| `fds_smb`     | `Super Mario Brothers (Japan).fds`                                   | The Famicom Disk System release.       |
| `ann_fds`     | `All Night Nippon Super Mario Brothers (Japan) (Promotion Card).fds` | All Night Nippon (Disk System).        |
| `smb2_jp_fds` | `Super Mario Brothers 2 (Japan).fds`                                 | Super Mario Bros. 2 (Disk System).     |

## What is edited

The kit's SMB profile defines every view; this repository only names the
revisions and the asset split. Each revision offers what its engine has:

- **World**: the world-to-area routes and the player physics tables, with the
  extended (All Night Nippon) and hard (SMB2) course sets as separate banks;
- **Levels**: every area header, terrain-object stream, enemy stream, entrance
  and page control, drawn on the game's own metatiles, with a playtest that
  starts from a chosen point on the cartridge revisions;
- **Screens** and **Text**: the title, status bar and other screens and the
  fixed-length game text;
- **Sound**: the music banks with a piano roll and preview, the swim/stomp
  envelope, the sound effects, and the Disk System ending suites of All Night
  Nippon and SMB2;
- **Graphics**, **Metatiles**, **Palettes** and **Animations**: CHR tiles, the
  2×2 metatiles, the area palette packets and the player's frames;
- **Demo**: the attract demo's inputs.

Every variable stream keeps its original allocation: level records can be
inserted or removed while the encoded stream fits its byte budget, and music
bytes are edited in place because channel offsets are part of the engine's
format. The kit refuses an edit that does not fit before it writes a ROM.

Vs. Super Mario Bros. plays on MAME's `suprmrio` arcade board: the kit lays the
build out as the board's ROM chips. It plays from power-on; starting from a
chosen point is not there yet for Vs. The Disk System revisions play on the
kit's OpenDiskSysROM unless a BIOS dump is installed in MAME.

## The game's names and tables

Retrolarium keeps nothing taken from the game; this repository gives it what it
needs. `config/names.json` holds the game's own names (the enemies, area objects
and player colours) in English. The studio and the kit read it when a project
opens and show the names as they are, untranslated; without it they show numbers
instead. Its `guard` list names what Retrolarium's own repositories must never
contain.

`config/game_profile.json` is the game's Retrolarium profile: its revisions with
their hashes and, for each resource, where it lies in each revision's image and
which codec reads it. The kit reads it when it opens `super_mario_bros.rlj` or a
project made from it; Retrolarium keeps no copy.

`config/profile_tables.json` names, by label, the tables the kit reads from the
image built from this source; `tools/profile_tables.py` in Retrolarium Kit turns
it into the offsets of `config/game_profile.json` for every revision.

## Checking the repository

`make studio-check` runs `rltool studio check super_mario_bros.rlj`. In a
throwaway copy of the repository it prepares every revision, decodes and
validates each document and rebuilds each revision with no edits, requiring the
original ROM or disk side byte for byte. It needs the revisions' ROMs and the
Retrolarium kit (`rltool` on `PATH`, or `RLTOOL=...`), and never reads or writes
`hack/` or `.retrolarium/`.

The data formats the repository's own gates prove stay here:
`scripts/build/data_formats.py` decodes and round-trips the representative
formats listed in `config/data_formats.json` (`make roundtrip-formats`), and the
relocation gate reads the music bank through
`scripts/validation/music_decoder.py`.

## Source Reconstruction 3.0

`config/source_reconstruction_3_0.json` is the 3.0 release manifest. It names the
descriptor, the profile and the revisions, the kit and studio versions the
release is checked with, and every removed editor with the view that replaced it.
`make source-3-audit` runs studio-check with `--release`, which also checks that
section against the descriptor and the running kit; `make source-3-check` runs
the functional Source 2.2 gate first. The 2.0, 2.1 and 2.2 manifests describe
their tags, so their audits run in a checkout of those tags
(`validation.tag_audit`).

## Reference editors

The data formats were implemented independently from the documented SMB1
formats; no third-party editor source is part of the project.

| Project                                                                                                   | Useful evidence                                                                   | Reuse decision                                        |
| --------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- | ----------------------------------------------------- |
| [SMB Utility](https://github.com/Maseya/SMB-Utility)                                                      | Visual workflow for SMB1 areas, objects, enemies, and test play from a position   | Reference only; AGPL-3.0 code is not incorporated     |
| [SMBLevelDrawer](https://github.com/IsoFrieze/SMBLevelDrawer)                                             | Cross-version area rendering for cartridge, FDS, Vs., and derivative releases     | Reference only; GPL-3.0 code is not incorporated      |
| [smb-vanilla-port](https://github.com/nukep/smb-vanilla-port)                                             | Engine-faithful behaviour and portable runtime architecture                       | Behavioural reference only; no source is incorporated |
| [Level-Headed](https://github.com/Coolcord/Level-Headed)                                                  | Enemy identifiers, area commands, and fixed-buffer constraints                    | Reference only; GPL-3.0 code is not incorporated      |
| [MushROMs SMB1 level format](https://github.com/bonimy/MushROMs/blob/master/doc/SMB1%20Level%20Format.md) | Bit-level documentation for headers, objects, page controls, enemies, transitions | Used to cross-check independently written codecs      |
| [SMBMusEdit](https://github.com/anakrusis/SMBMusEdit)                                                     | Song headers, shared streams, allocation limits, and playback                     | Reference only; the repository declares no license    |
| [MarioNESEditor](https://github.com/howerpower/MarioNESEditor)                                            | SMB-specific CHR browsing and pixel editing                                       | Reference only; the repository declares no license    |
| [SMB1Base](https://github.com/smbstudio/smb1base)                                                         | Modern hacking workflow and compatibility with established level tools            | Architectural reference only                          |
