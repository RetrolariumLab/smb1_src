# Super Mario Bros Disassembly

A comprehensive disassembly of Super Mario Bros for the Nintendo Entertainment System (NES).

The current release is **Source Reconstruction 3.0**: editing moves to
[Retrolarium](docs/retrolarium.md). Open `super_mario_bros.rlj` in Retrolarium
Studio to edit any of the seven revisions; the repository keeps the
byte-identical source, its builds and checks, the game's names and the tables
the kit reads. Original ROMs, disk images, CHR payloads, and extracted content
remain private ignored inputs.

The immutable `source-reconstruction-1.0`, `-2.0`, `-2.1` and `-2.2` tags
preserve their original release contracts; 2.1 and 2.2 add relocation proofs,
platform profiles, semantic evidence and the SMB2 sibling engine to 2.0, and the
Tkinter studios they carried stay in history there.

`make source-3-check` runs the functional 2.2 gate and then checks every
revision in Retrolarium Kit. See [`docs/retrolarium.md`](docs/retrolarium.md).

## Overview

This repository contains:

- **src/main.asm** - Address-ordered entrypoint for the modular disassembly
- **config/linker/** - Linker contracts for native, expanded, FDS, and ANN payloads
- **docs/index.md** - Documentation map by release, architecture, runtime, and data format topic
- **docs/retrolarium.md** - Editing the game in Retrolarium and the checks that prove it
- **docs/6502_reference.md** - NES 6502 instructions, flags, and opcodes
- **docs/modding_examples.md** - Example gameplay edits and patch ideas
- **docs/naming.md** - Semantic symbol vocabulary and evidence rules
- **docs/player_movement.md** - Player input, physics, collision, and traces
- **docs/ram_fields.md** - Verified semantic RAM-field registry
- **docs/subsystems.md** - Address-ordered system architecture and ownership
- **docs/unknowns.md** - Stable uncertainty and evidence registry
- **docs/debugger_workflow.md** - Mesen/FCEUX symbols and source navigation
- **docs/runtime_evidence.md** - Deterministic gameplay transaction scenarios
- **docs/data_formats.md** - Typed authored-data codecs and byte round trips
- **config/reconstruction/label_renames.json** - Canonical original-to-current symbol map
- **docs/licensing.md** - Licensing and distribution status by material class
- **docs/preservation_source_1_0.md** - Stable release scope and evidence boundary
- **docs/source_reconstruction_2_0.md** - Aggregate 2.0 scope and acceptance gate
- **docs/source_reconstruction_2_1.md** - Published 2.1 milestones and boundaries
- **docs/source_reconstruction_2_2.md** - Compatible modernization scope and release gate
- **docs/relocation_testing.md** - Generated address-shift and runtime proof
- **CONTRIBUTING.md** - Safe source, data, evidence, and verification workflow

## Project Structure

```text
smb1_src/
|-- assets/
|   |-- manifest.json   # Reference identity and extracted-asset hashes
|   `-- generated/      # Ignored local container, graphics, and content assets
|-- config/
|   |-- debugger/       # Breakpoint and watch contracts
|   |-- linker/         # Native, expanded, FDS, and ANN linker contracts
|   `-- reconstruction/ # Later-engine and sibling-source contracts
|-- docs/               # Local technical notes
|   |-- 6502_reference.md
|   `-- modding_examples.md
|-- mk/                 # Make orchestration grouped by workflow
|-- scripts/            # Categorized build, validation, runtime, and workflow tools
|   |-- build/          # Builds, images, assets, and profile composition
|   |-- runtime/        # Emulator runners and runtime validators
|   |-- validation/     # Lint, release, relocation, and artifact audits
|   `-- workflow/       # Reconstruction workflows and Lua automation
|-- src/                # Assembly source
|   |-- audio/          # Sound effects, music engine, and music data
|   |-- data/           # Level streams and fixed interrupt vectors
|   |-- game/           # Modes, physics, objects, enemies, and collisions
|   |-- main.asm
|   |-- memory/         # Hardware, RAM, and assembly-time definitions
|   |-- rendering/      # Screens, backgrounds, HUD, and actor composition
|   `-- system/         # Reset, frame control, input, and PPU I/O
|-- tests/              # Tests mirroring scripts/ responsibilities
|-- Makefile            # Main build entrypoint
|-- README.md
`-- .gitignore
```

## Prerequisites

The build assembles with the `ca65` and `ld65` that
Retrolarium Kit ships; `RLTOOL` names the kit
command (default `rltool`). See [`docs/toolchain.md`](docs/toolchain.md).

The preservation profile currently targets exactly:

```text
Super Mario Bros. (JU) [!].nes
SHA-1 ea343f4e445a9050d4b4fbac2c77d0693b1d0922
```

Place a legally obtained matching ROM in the project root, then run:

```bash
make split
```

This validates the complete ROM identity before extracting:

- `assets/generated/header/smb.hdr` - 16-byte iNES header;
- `assets/generated/chr/smb.chr` - 8192-byte CHR-ROM payload;
- two typed course packs containing the enemy and area-object streams;
- one bounded music-data pack containing streams, lookup tables, and envelopes;
- one bounded area-palette pack shared by the console and disk profiles;
- one bounded 2x2 metatile graphics pack.

The ROM and extracted files are ignored and are not included in the repository.
PAL revisions and ROMs with extra trailing payloads are rejected by default.

## Building

### Preservation PRG build

After the one-time `make split`, the reconstruction can be assembled and
checked without retaining the ROM image:

```bash
make build-prg
make verify-prg
```

`make verify-prg` writes the PRG, labels, linker map, and debug information
under the ignored `build/native/` directory. It fails unless the 32 KiB PRG is
byte-identical to the recorded baseline in `assets/manifest.json`.

### Using Makefile

Run `make help` for the stable command groups and common entrypoints.

```bash
# Check tracked text, assembly style, semantic source, and documentation
make lint

# Normalize assembly formatting and run the same checks
make format

# Run focused Python tooling tests
make test

# Generate Mesen/FCEUX symbols and validate them in live FCEUX
make symbols
make validate-symbols

# Replay and validate focused gameplay transactions
make trace-runtime

# Run the complete live debugger and emulator evidence layer
make trace

# Decode, re-encode, and compare representative authored data
make roundtrip-formats

# Run every Preservation Source 1.0 acceptance gate
make release-check

# Run Preservation Source 1.0 plus the functional Source Reconstruction 2.0 gates
make source-2-functional-check

# Add relocation, semantic evidence and the SMB2 sibling (2.1), then the 2.2 toolchain
make source-2-1-functional-check
make source-2-2-functional-check

# Verify the pinned assembler, linker, emulator, source commit, and FDS BIOS
make check-source-2-1-toolchain

# Audit the 2.0, 2.1 and 2.2 manifests in checkouts of their tags
make source-2-audit
make source-2-1-audit
make source-2-2-audit

# Check structure, tests, and release metadata without private ROMs
make scaffold-check

# Run the complete Source Reconstruction 3.0 gate: 2.2 functional, then Retrolarium
make source-3-check

# Compare normalized ANN and SMB2 instruction streams
make later-engine-source-overlap

# Rebuild SMB2 / The Lost Levels and verify the complete FDS side
make verify-smb2

# Prove SMB2 startup and all three normal FDS overlay-load paths
make validate-smb2-runtime
make validate-smb2-overlays

# Exercise World 1-1 and prove all four programs survive controlled relocation
make validate-smb2-gameplay
make validate-smb2-relocation

# Build and statically validate the generated canonical relocation candidate
make test-relocation

# Run debugger and complete runtime evidence against the relocation candidate
make validate-relocation

# Build and validate the JU, PlayChoice-10, and PAL relocation matrix
make test-relocation-revisions
make validate-relocation-revisions

# Build and validate the isolated fixed-layout demonstrator
make validate-hack

# Build and validate the isolated CNROM profile
make validate-expanded

# Check every revision in Retrolarium Kit with no edits
make studio-check

# Verify and run all supported official profiles
make verify-revisions
make validate-revisions

# Extract private assets for every supported ROM and verify the complete matrix
make split-all
make verify-all

# Extract private Vs. container assets once, then verify its full image and runtime
make split-platform-assets PLATFORM=vs_smb
make verify-platform PLATFORM=vs_smb
make validate-platform PLATFORM=vs_smb

# Extract the private FDS template once, then verify the exact rebuilt disk side
make split-platform-assets PLATFORM=fds_smb
make verify-platform PLATFORM=fds_smb

# Validate local assets and build build/native/smb.nes
make build

# Rebuild and require complete byte identity with the reference ROM
make verify

# Validate extracted assets without changing them
make check-assets

# Remove build/native safely; extracted assets remain untouched
make clean
```

The Makefile contains only thin entrypoints. Assembly-style validation, ROM
parsing, safe extraction, assembly, linking, concatenation, checksum validation,
and cleanup are implemented in platform-independent Python scripts under
`scripts/`. See [`docs/assembly_style.md`](docs/assembly_style.md) for the checked
source conventions and [`docs/naming.md`](docs/naming.md) for the semantic symbol
vocabulary. See [`docs/debugger_workflow.md`](docs/debugger_workflow.md) for
interactive source navigation and [`docs/runtime_evidence.md`](docs/runtime_evidence.md)
for reproducible emulator evidence.
The reversible data contracts are documented in
[`docs/data_formats.md`](docs/data_formats.md).
Contribution rules and the stable-release boundary are documented in
[`CONTRIBUTING.md`](CONTRIBUTING.md) and
[`docs/preservation_source_1_0.md`](docs/preservation_source_1_0.md).

## Modding Notes

For a few practical modification examples, see [docs/modding_examples.md](docs/modding_examples.md).

## Credits

- **Disassembly** - doppelganger (doppelheathen@gmail.com)
- **Original source** - https://gist.github.com/1wErt3r/4048722
- **ca65-adapted source and build instructions** - https://xynosan.neocities.org/smb/
- **cc65 toolchain** - http://www.cc65.org/
- **Runtime input movie** - DJ Incendration,
  [fixture provenance](movies/README.md),
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
