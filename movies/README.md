# Runtime Input Fixture

`tas.rlmovie` is a deterministic controller-input movie that `make test-full`
plays in MAME (`tas.check.json`). It is a third-party test fixture, not part
of the Super Mario Bros. program or asset reconstruction.

## Provenance and License

| Field | Value |
| --- | --- |
| Title | SMB1 human theory TAS |
| Author | DJ Incendration (`DJ_Incendration` on TASVideos) |
| Original filename | `Smb1 human theory TAS.fm2` |
| Source | [TASVideos User File 68410246126700593](https://tasvideos.org/UserFiles/Info/68410246126700593) |
| Uploaded | December 28, 2020 |
| License | [Creative Commons Attribution 2.0](https://creativecommons.org/licenses/by/2.0/) |
| Size | 268,205 bytes |
| SHA-1 | `fbbb675af9b85146015713b8ca5c488d6c0053ab` |

The tracked movie is the TASVideos download (the size and SHA-1 above)
converted from FCEUX's `.fm2` to Retrolarium's run-length `.rlmovie` with
`rltool movie convert`; the frames and inputs are unchanged. The author,
source page, title, tool-assisted nature, and license are retained here to
satisfy the attribution conditions for redistribution.

## Content Boundary

The movie holds controller states only. It does not contain the ROM, PRG,
CHR, screenshots, audio, or an emulator save state.

The full test replays this input from power-on and compares the game's state at
six checkpoints with what the original ROM gives.
