# Documentation Index

Start here; read [`CONTRIBUTING.md`](../CONTRIBUTING.md) before changing emitted
bytes.

## Project

- [`retrolarium.md`](retrolarium.md) — editing every revision in Retrolarium
  Studio, the game's names and tables, `make studio-check`.
- [`licensing.md`](licensing.md) — licensing and distribution status.
- [`toolchain.md`](toolchain.md) — the cc65 Retrolarium Kit ships.

## Source

- [`source_layout.md`](source_layout.md) — address-ordered module map and linker
  boundaries.
- [`subsystems.md`](subsystems.md) — runtime ownership and subsystem
  interactions.
- [`ram_fields.md`](ram_fields.md) — RAM symbol registry.
- [`naming.md`](naming.md) — symbol vocabulary.
- [`assembly_style.md`](assembly_style.md) — assembly conventions.
- [`unknowns.md`](unknowns.md) — open and closed questions.
- [`player_movement.md`](player_movement.md) — input, physics, collision.
- [`data_formats.md`](data_formats.md) — worlds, areas, enemies and music, as
  the engine reads them.
- A 6502 instruction reference: <https://www.nesdev.org/obelisk-6502-guide/>.

## Builds and profiles

- [`revisions.md`](revisions.md) — the seven images: how each is built and what
  is special about it.
- [`modding_examples.md`](modding_examples.md) — practical source changes.

## Checks

`make test` must pass after every change: among other things it rebuilds every
image that is present (`assets/manifest.json` names them) and requires it byte
for byte. `make test-full` also plays the TAS in MAME on the relocated build
(see the README).
