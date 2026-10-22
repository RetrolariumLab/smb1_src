# Super Mario Bros Disassembly

The 6502 source of Super Mario Bros. for the NES as readable ca65 modules, built
back byte for byte into the original images: the Japan/USA cartridge, the PAL
and PlayChoice-10 revisions, Vs. Super Mario Bros., the Famicom Disk System
releases, All Night Nippon Super Mario Bros. and Super Mario Bros. 2 (Japan).

## Status

Source Reconstruction 3.1. Editing happens in Retrolarium Studio: open
`super_mario_bros.rlj` to edit any of the seven revisions
([`docs/retrolarium.md`](docs/retrolarium.md)). The repository keeps the source,
its builds and checks, the game's names and the tables the kit reads.

3.1 keeps only what builds and checks the source. The earlier releases' audits,
runtime traces, semantic evidence, analysis tools and the FCEUX tooling remain
in the history (tags `source-reconstruction-1.0` to `3.0`).

## Quick start

You need Python 3, GNU Make and Retrolarium Kit (`rltool` on `PATH`, or
`RLTOOL=...`); the kit supplies and verifies ca65 and ld65
([`docs/toolchain.md`](docs/toolchain.md)). Copy your
`Super Mario Bros. (JU) [!].nes` into the repository root, then:

```bash
make split     # cut the CHR, courses, music, palettes and metatiles out (once)
make verify    # build JU and compare it byte for byte
```

`make` alone lists the targets. `make split` cuts the assets out of every ROM
and disk image that is here (PAL, PlayChoice-10, Vs., FDS, ANN, SMB2; see
[`docs/revisions.md`](docs/revisions.md)); start the documentation at
[`docs/index.md`](docs/index.md). `assets/manifest.json` names the images and
the assets (`rltool assets`, Retrolarium Kit). The images and the extracted
files under `assets/generated/` are ignored.

## Targets

```bash
make build [REVISION=<id>]    # into build/revisions/<id>/; ju, pal, pc10,
make verify [REVISION=<id>]   # vs_smb, fds_smb, ann_fds or smb2_jp_fds
make verify-revisions         # every image that is here, byte for byte
make build-relocated          # the JU ROM with its code moved
make studio-check             # open and rebuild the revisions here
make profile-check            # the profile's table places against the builds
make test / test-full / golden
make play [MOVIE=tas]         # watch a movie in MAME
make lint / format / hooks / clean
```

## Tests

`make test` (about half a minute) verifies every image that is present byte for
byte (the cartridges, the Vs. ROM and the three disks), builds the relocated JU
ROM (a byte inserted at nine points of `src/main.asm`, absorbed by the padding
before the audio code and the synthesis tables), checks the profile's table
places and runs the studio check.

`make test-full` (about a minute and a half) adds the any% TAS
`movies/tas.rlmovie`, played in MAME on the relocated build. At six checkpoints,
the last at the end of World 8-4, the game's state (mode, world, level, area,
lives, status, coins, score) must equal what the original ROM gives, as
`movies/tas.check.json` records. Name MAME once with `rltool movie mame <path>`
(or `MAME=<path>`); `make golden` records the reference values again.

`make play MOVIE=tas` shows a movie in a MAME window at the game's speed, on the
relocated build (or on `ROM=<image>`), and compares its cells with the
original's once the window is closed; in MAME, F10 lifts the speed limit and
Insert fast-forwards. `FRAMES=<frame>` closes MAME at that frame, `CLOSE=1` when
the movie ends. `make play` alone plays `tas`.

## Layout

```text
src/              ca65 source: main.asm, the game, platforms, revisions
config/           linker layouts, lint, the Retrolarium profile, its tables
                  and names
assets/           manifest.json (the generated assets are ignored)
movies/           the TAS, its provenance and its check
docs/             how the game works and how the source is written
super_mario_bros.rlj   the Retrolarium project
```

## Modding notes

For a few practical modification examples, see
[docs/modding_examples.md](docs/modding_examples.md).

## Credits

- **Disassembly** - doppelganger (doppelheathen@gmail.com)
- **Original source** - https://gist.github.com/1wErt3r/4048722
- **ca65-adapted source and build instructions** -
  https://xynosan.neocities.org/smb/
- **cc65 toolchain** - http://www.cc65.org/
- **TAS** - DJ Incendration, [fixture provenance](movies/README.md),
  [TASVideos user file 68410246126700593](https://tasvideos.org/UserFiles/Info/68410246126700593)
- **Original game** - Nintendo

## Trademarks

This is an unofficial reconstruction, made for study and preservation. The game,
its title and its characters are trademarks of their owners, who have not made,
licensed or endorsed this project. It contains no part of the game: you need
your own copy of Super Mario Bros. to build anything.

## License

This is a work of reverse engineering for educational and preservation purposes.
The original game is copyright Nintendo, and this repository grants no license
to Nintendo's game code or assets. Tool and imported-material status is detailed
in [docs/licensing.md](docs/licensing.md).
