# Toolchain

The build assembles and links with `ca65` and `ld65` from cc65 2.19, upstream
revision `0fca835`, as Retrolarium Kit builds, ships and verifies them. The
Makefile asks the kit for each program once (`rltool build-tools path nes
ca65`); `RLTOOL` names the kit command and defaults to `rltool`. This
repository holds no executables, and the kit carries cc65's zlib license with
the binaries.

Both programs report:

```text
ca65 V2.19 - Git 0fca835
ld65 V2.19 - Git 0fca835
```

`make verify` and the other byte-identity checks do not depend on the
binaries: whichever `ca65` and `ld65` run, the complete images must still come
out exactly.

The Windows binaries Source Reconstruction 2.1 and 2.2 shipped stay at those
release tags.
