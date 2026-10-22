# Revisions

The source builds seven images, each byte for byte: three cartridges, the Vs.
System board and three Disk System sides. `assets/manifest.json` names every ROM
and disk by file, size and SHA-1 (its image id is the revision's name) and lists
what `make split` cuts out of each; the game's content always comes from there,
never from this repository.

`make build REVISION=<id>` assembles the revision's entry file into
`build/revisions/<id>/` (JU unless given); `make verify` also compares the
result with the image, and `make verify-revisions` does so for every image that
is here. Every revision also takes JU's assets, so the JU ROM is always needed.

| Revision      | Entry file                     | Image      | Linker config |
| ------------- | ------------------------------ | ---------- | ------------- |
| `ju`          | `src/revisions/ju.asm`         | `smb.nes`  | `nrom256.cfg` |
| `pal`         | `src/revisions/pal.asm`        | `smb.nes`  | `nrom256.cfg` |
| `pc10`        | `src/revisions/pc10.asm`       | `smb.nes`  | `nrom256.cfg` |
| `vs_smb`      | `src/revisions/vs.asm`         | `smb.nes`  | `nrom256.cfg` |
| `fds_smb`     | `src/revisions/fds_smb.asm`    | `smb.fds`  | `fds_prg.cfg` |
| `ann_fds`     | `src/revisions/ann/build.asm`  | `smb.fds`  | `ann.cfg`     |
| `smb2_jp_fds` | `src/revisions/smb2/build.asm` | `smb2.fds` | `smb2.cfg`    |

Each entry file sets `con_revision_profile` (`src/revisions/profile_ids.inc`)
before it includes the shared source. Revision differences are source
alternatives selected by that profile, never patches applied after linking.

## Cartridges

A cartridge entry file includes `src/main.asm` and then
`src/revisions/cartridge.inc`, which writes the iNES header and includes the
CHR, so ld65 links the whole image.

- **JU** (Japan/USA) is the base revision.
- **PlayChoice-10** is JU's program with an 8 KiB instruction ROM after the CHR,
  which `make split` cuts from the PlayChoice ROM.
- **PAL** (the European release commonly called Rev A) changes timing, physics,
  audio, collision and padding in the source, and takes its own course and music
  packs: two enemy-stream and twelve area-stream bytes differ from JU, and its
  victory padding, pitch periods and note lengths. Another European image, an
  alternate candidate of uncertain provenance, is not supported.
- **Vs. Super Mario Bros.** (the Vs. System board) selects its input, coin,
  DIP-switch, PPU, title, game-over, level, rendering and audio code from the
  source. It has its own header (mapper 99), 16 KiB CHR, a 1,745-byte music pack
  with its extra streams, and eight arcade area-palette packets.

## Disk System

A disk build links the program files and then writes them into a copy of the
side `make split` keeps (`rltool fds write`), which supplies the disk's
metadata, license, CHR and save records; the whole side must equal the disk.

- **FDS SMB1** is the early engine moved to the Disk System memory map: the
  `$6000-$DFFF` load map, FDS reset and interrupt handling, the BIOS stack
  workspace and its alignment bytes. Its one program file, `SMMAIN`, fills disk
  files 3 and 4.
- **All Night Nippon** is an official promotional release on the later disk
  engine it shares with SMB2: its own graphics, courses, physics, ending, audio
  and disk files. `src/revisions/ann/build.asm` assembles the main program
  `NSMMAIN` and the three overlay files `NSMDATA2` (supplemental courses),
  `NSMDATA3` (ending and its audio engine) and `NSMDATA4` (hard courses) as one
  unit, each overlay in its own scope, so the overlays call the main program by
  name. Its course, guest-CHR, metatile and music packs are cut from the disk;
  the main program has no victory stream, which the source keeps as a zero-size
  alias.
- **Super Mario Bros. 2** (The Lost Levels) is the later engine's other release.
  `src/revisions/smb2/build.asm` assembles its four program files as one unit,
  each in its own scope:

| File       | Load address |   Size | Holds                              |
| ---------- | -----------: | -----: | ---------------------------------- |
| `SM2MAIN`  |      `$6000` | 32,768 | main engine and worlds 1-4         |
| `SM2DATA2` |      `$C470` |  3,631 | worlds 5-8 and gameplay extensions |
| `SM2DATA3` |      `$C5D0` |  3,279 | ending, World 9 and the disk music |
| `SM2DATA4` |      `$C2B4` |  3,916 | worlds A-D and gameplay extensions |

The SMB2 code keeps the names of doppelganger's SMB2J disassembly (see
[naming](naming.md)); its content comes from the program files `make split` cuts
from the disk. Before the save byte at `$D29F` the main program has 83 unused
`$FF` bytes. Shared late-engine code (the upside-down pipe, the hard-course
loader and the checkpoint initializer) lives in
`src/platforms/late_fds/common/`.

A GoodNES `.nes` conversion of All Night Nippon exists; it is an unofficial
cartridge conversion, not a revision.
