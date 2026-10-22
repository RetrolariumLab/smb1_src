# SMB2 Late-FDS Revision Reconstruction

Japanese Super Mario Bros. 2 / The Lost Levels entered Source Reconstruction
2.1 as an independently verified sibling engine. Post-release instruction-flow
comparison established that it and ANN are revisions of one late-FDS engine.
They retain independent payload entrypoints and byte-identity contracts while
shared code is promoted only where equivalence has been measured.

The first shared promotion is complete: the upside-down-pipe runtime,
hard-course loader, and checkpoint initializer now live under
`src/platforms/late_fds/common/`. Together they cover the complete
168-instruction hard-course match measured between ANN and SMB2; revision-owned
tables and wind/spring extensions remain separate.

The feasibility evidence connects 40,349 of 52,075 same-ID payload bytes to
ANN, and the corresponding FDS images use the same eight file roles. The low
same-address ratios nevertheless prove that the main program and overlays have
their own layouts. The project therefore reuses infrastructure and reviewed
knowledge, not an engine-wide web of `.if SMB2` alternatives.

## Source Boundary

SMB2 payload entrypoints live under `src/revisions/smb2/`, symmetrically with
ANN. Its current implementation modules live under
`src/platforms/late_fds/smb2/`; independently proven common modules are promoted
to `src/platforms/late_fds/common/`. The cartridge-era SMB1 modules keep their
Source Reconstruction 2.0 meaning and may not acquire SMB2 selection
conditionals. Modules remain small enough to review while representing complete
responsibilities rather than dozens of tiny instruction fragments.

Each program payload has an independent entrypoint and linker contract:

| Payload | Load address | Size | Role |
| --- | ---: | ---: | --- |
| `SM2MAIN` | `$6000` | 32,768 | Main engine and worlds 1-4 |
| `SM2DATA2` | `$C470` | 3,631 | Worlds 5-8 and loaded gameplay extensions |
| `SM2DATA3` | `$C5D0` | 3,279 | Ending, World 9, and FDS music |
| `SM2DATA4` | `$C2B4` | 3,916 | Worlds A-D and loaded gameplay extensions |

`make split` hash-checks the original disk and keeps a copy of the side
beneath the ignored `assets/generated/platforms/smb2_jp_fds/`; ordinary builds
never split or overwrite it.

The reconstruction uses no private program payloads. The pinned
listings are normalized into 52 source files across the SMB2 revision and
late-FDS platform trees, with the largest responsibility-owned module remaining
below 700 lines. Implementation modules use `.asm`; `.inc` is reserved for
declarations and interfaces. `make build-smb2-source`
assembles one scoped ca65 unit so cross-overlay imports retain their original
meaning, then emits `SM2MAIN`, `SM2DATA2`, `SM2DATA3`, and `SM2DATA4` as four
separate files, and reports each payload's identity.
`make verify-revision REVISION=smb2_jp_fds` writes the source-built programs over
their file records in the private side, which keeps the license, CHR, and save
records, and requires SHA-1
`20e50128742162ee47561db9e82b2836399c880c` for the complete disk side.

## Relocation

The main program contains 83 source-declared unused `$FF` bytes immediately
before the save byte at `$D29F`. Releases 2.x and 3.0 built a candidate with
eight `$EA` probes across the system, frame, area, player, enemy, collision,
disk and course boundaries, absorbed by that padding, and checked that 1,860
`SM2MAIN` labels moved while the save byte, the `$D29F..$DFF9` audio ABI and
316 overlay labels stayed put. That check remains at those tags; no movie
plays SMB2 yet.

Executable payloads must be visible assembly; `.incbin` is forbidden for code.
The game's content (courses, music, palettes, metatiles, the title screen,
texts and the ending) is not in the source: each label takes its bytes with
`.incbin` from the program files `make split` cuts out of the disk
(`assets/generated/programs/SM2MAIN.bin` and the three `SM2DATA` files). CHR,
license data, and the save byte remain ignored private assets extracted from
the hash-checked original disk. No raw ROM, FDS, or CHR image is tracked.

## Verification Reference

The ignored `references/threecreepio-smb2j` checkout is the ca65 port of
doppelganger's comprehensive SMB2J disassembly at commit
`9c40114626ecd07f13e16d5e67e217b98482d7af`. Its README provides the source
as-is. Building it locally with the project's ca65/ld65 produces SHA-1
`20e50128742162ee47561db9e82b2836399c880c`, exactly matching the private FDS
reference. It is a verification oracle and naming aid, not a directory layout
to copy. The much more fragmented `segaloco-smb` meta-disassembly remains a
secondary cross-check for relationships between SMB2 and ANN.

The import (tag 3.0 keeps its tool and the mapping of all 2,383 original
colon labels plus three callable FDS BIOS constants) reused, for exact original
matches, reuse 1,935 already reviewed SMB1 semantic stems while recomputing their
roles for SMB2; another 112 later-engine-only abbreviations have direct reviewed
expansions. The remaining records retain descriptive SMB2 reference semantics,
primarily course, message, and music data, instead of inventing unsupported
interpretations.

## Promotion Order

1. Add exact disk identity, extraction, private-template, and four-payload build
   contracts.
2. Import and normalize the four program listings into reviewed project source,
   then split them by meaningful responsibility without changing bytes.
3. Apply the project ASM style and semantic snake_case naming while retaining a
   generated original-name mapping.
4. Prove runtime startup, overlay transitions, course behavior, and relocation
   independently from ANN.
5. Make SMB2 editable only after its pointer tables, capacities, and output
   composition are proven for all relevant payloads.

Code is shared only after independent static and runtime evidence establishes
equivalence; similar bytes, matching addresses, or a common historical ancestor
are not sufficient promotion criteria.
