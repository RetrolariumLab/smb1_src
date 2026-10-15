# Contributing to the SMB1 Preservation Source

The original Super Mario Bros. instruction stream, layout, data and timing are
the baseline: every supported image must keep building byte for byte.

## Local inputs

Use a legally obtained ROM matching SHA-1
`ea343f4e445a9050d4b4fbac2c77d0693b1d0922` and run `make split` once. Never add
ROMs, disk images, extracted assets or anything under `build/` to Git. The other
revisions and platforms are optional local inputs (`make split-all`).

## Source changes

Keep `src/main.asm` in address order. Use the names of `docs/naming.md` and the
layout of `docs/assembly_style.md`; record an uncertain reading in
`docs/unknowns.md` rather than presenting a guess as fact.

For each change:

```bash
make format
make test
```

Run `make test-full` (MAME) after changing control flow, physics or anything
timing-sensitive. Behaviour-changing work belongs to the variant entrypoints
(`docs/variants.md`) and must not weaken the default builds. Data is edited in
Retrolarium Studio (`docs/retrolarium.md`).

`make hooks` installs Git hooks that check commits and pushes for words that
must not be published and run `make lint` before each commit.
