# Toolchain

The build assembles and links with `ca65` and `ld65` from cc65 2.19, upstream
revision `0fca835`, as Retrolarium Kit builds and ships them. The build scripts
ask the kit for each program (`rltool build-tools path nes ca65`); `RLTOOL`
names the kit command and defaults to `rltool`. A `ca65` or `ld65` on `PATH` is
used only when the kit cannot be run. This repository holds no executables, and
the kit carries cc65's zlib license with the binaries.

Both programs report:

```text
ca65 V2.19 - Git 0fca835
ld65 V2.19 - Git 0fca835
```

`make verify` and the other byte-identity gates are independent of the tool
binaries: whichever `ca65` and `ld65` run, the reference PRG and complete ROM
must still be reproduced exactly.

## Released toolchains

Source Reconstruction 2.1 and 2.2 shipped the Windows executables in `bin/`,
taken unchanged from the official cc65 snapshot workflow (Snapshot Build 795).
Those files, their provenance record (`bin/README.md`), and the license notice
(`bin/cc65-LICENSE.txt`) remain at the release tags `source-reconstruction-2.1`
and `source-reconstruction-2.2`, pinned as:

| File       |          Size | SHA-256                                                            |
| ---------- | ------------: | ------------------------------------------------------------------ |
| `ca65.exe` | 721,629 bytes | `9109d7118ff070e78f031bee4eb776061e56b74e7c8f9f40c70fd6707ea0ac5a` |
| `ld65.exe` | 575,874 bytes | `5f68367a135c578c88744e27ba0b1234604d87ef1ff6294b46fcb031ff984db4` |

 Toolchain

The build assembles and links with `ca65` and `ld65` from cc65 2.19, upstream
revision `0fca835`, as Retrolarium Kit builds and ships them. The build scripts
ask the kit for each program (`rltool build-tools path nes ca65`); `RLTOOL`
names the kit command and defaults to `rltool`. A `ca65` or `ld65` on `PATH` is
used only when the kit cannot be run. This repository holds no executables, and
the kit carries cc65's zlib license with the binaries.

Both programs report:

```text
ca65 V2.19 - Git 0fca835
ld65 V2.19 - Git 0fca835
```

`make verify` and the other byte-identity gates are independent of the tool
binaries: whichever `ca65` and `ld65` run, the reference PRG and complete ROM
must still be reproduced exactly.

## Released toolchains

Source Reconstruction 2.1 and 2.2 shipped the Windows executables in `bin/`,
taken unchanged from the official cc65 snapshot workflow (Snapshot Build 795).
Those files, their provenance record (`bin/README.md`), and the license notice
(`bin/cc65-LICENSE.txt`) remain at the release tags `source-reconstruction-2.1`
and `source-reconstruction-2.2`, pinned as:

| File       |          Size | SHA-256                                                            |
| ---------- | ------------: | ------------------------------------------------------------------ |
| `ca65.exe` | 721,629 bytes | `9109d7118ff070e78f031bee4eb776061e56b74e7c8f9f40c70fd6707ea0ac5a` |
| `ld65.exe` | 575,874 bytes | `5f68367a135c578c88744e27ba0b1234604d87ef1ff6294b46fcb031ff984db4` |

`make check-source-2-1-toolchain` and `make check-source-2-2-toolchain` read the
pinned files from their tags, check size, hash, and version, and require the
kit's programs to report the same cc65 version.
