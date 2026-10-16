# Documentation Index

Start here; read [`CONTRIBUTING.md`](../CONTRIBUTING.md) before changing emitted
bytes.

## Project

- [`retrolarium.md`](retrolarium.md) — editing every revision in Retrolarium
  Studio, the game's names and tables, `make studio-check`.
- [`licensing.md`](licensing.md) — licensing and distribution status.
- [`toolchain.md`](toolchain.md) — the cc65 Retrolarium Kit ships and the
  released toolchains.

## Source

- [`source_layout.md`](source_layout.md) — address-ordered module map and linker
  boundaries.
- [`subsystems.md`](subsystems.md) — runtime ownership and subsystem
  interactions.
- [`ram_fields.md`](ram_fields.md) — RAM symbol registry.
- [`naming.md`](naming.md) — symbol vocabulary.
- [`assembly_style.md`](assembly_style.md) — assembly conventions.
- [`6502_reference.md`](6502_reference.md) — 6502 instruction reference.
- [`unknowns.md`](unknowns.md) — open and closed questions.
- [`player_movement.md`](player_movement.md) — input, physics, collision.

## Builds and profiles

- [`revision_profiles.md`](revision_profiles.md) — the cartridge revisions.
- [`platform_profiles.md`](platform_profiles.md) — NES, Vs. System and FDS
  profiles, All Night Nippon.
- [`smb2_reconstruction.md`](smb2_reconstruction.md) — Super Mario Bros. 2 (FDS).
- [`modding_examples.md`](modding_examples.md) — practical source changes.

## Checks

`make test` must pass after every change: among other things it rebuilds every
image that is present (`assets/manifest.json` names them) and requires it byte for byte. `make test-full` also plays
the TAS in MAME on the relocated build (see the README).
