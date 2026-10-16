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
in the history (tags `source-reconstruction-1.0` to `3.0`). Expanded ROMs and
hacks return with extended editing in Retrolarium in a later release; 3.0 had
a CNROM variant and a five-lives hack.

## Quick start

You need Python 3, GNU Make and Retrolarium Kit (`rltool` on `PATH`, or
`RLTOOL=...`); the kit supplies the pinned ca65 and ld65
([`docs/toolchain.md`](docs/toolchain.md)). Copy your
`Super Mario Bros. (JU) [!].nes` (SHA-1
`ea343f4e445a9050d4b4fbac2c77d0693b1d0922`) into the repository root, then:

```bash
make split     # unpack header, CHR, courses, music, palettes and metatiles (once)
make verify    # build and compare byte for byte
```

The ROM and the extracted files under `assets/generated/` are ignored.
`make split-all` unpacks every other image that is present (PAL, PlayChoice-10,
Vs., FDS, ANN; their names are in [`docs/revision_profiles.md`](docs/revision_profiles.md)
and [`docs/platform_profiles.md`](docs/platform_profiles.md)).

## Targets

```bash
make build / verify                                 # the JU ROM
make verify-revision PROFILE=pal|pc10               # the other cartridge revisions
make verify-platform PLATFORM=vs_smb|fds_smb|ann_fds
make verify-all                                     # every image that is here
make build-smb2 / verify-smb2                       # Super Mario Bros. 2 (Japan)
make build-ann-payloads                             # the ANN courses and ending
make build-relocated                                # the JU ROM with its code moved
make studio-check                                   # open and rebuild every revision
make test / test-full / golden                      # the checks
make lint / format / hooks / clean / help
```

## Tests

`make test` (about half a minute) runs the unit tests of the build scripts,
verifies every image that is present byte for byte, the SMB2 disk and the
ANN payloads, builds the relocated JU ROM (a byte inserted at
nine points, absorbed by the padding before the audio code and the synthesis
tables) and runs the studio check.

`make test-full` (about a minute and a half) adds the any% TAS
`movies/smb1_any_percent.fm2`, played in MAME on the relocated build. At six
checkpoints, the last at the end of World 8-4, the game's
state (mode, world, level, area, lives, status, coins, score) must equal what
the original ROM gives, as `movies/smb1_any_percent.check.json` records. Name
MAME with `MAME=<path>` or `RETROLARIUM_MAME`; `make golden` records the
reference values again.

## Layout

```text
src/              ca65 source: main.asm, the game, platforms, revisions
config/           profiles, linker layouts, the relocation manifest, lint,
                  the Retrolarium profile and names
assets/           manifest.json (the generated assets are ignored)
scripts/          build, split, relocation and verification scripts (scripts/run.py runs them)
tests/            their unit tests
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
- **ca65-adapted source and build instructions** - https://xynosan.neocities.org/smb/
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

This is a work of reverse engineering for educational and preservation
purposes. The original game is copyright Nintendo, and this repository grants
no license to Nintendo's game code or assets. Tool and imported-material status
is detailed in [docs/licensing.md](docs/licensing.md).
