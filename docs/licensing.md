# Licensing and Distribution Status

This repository separates technical provenance from permission to distribute
copyrighted material. Byte identity, source attribution, and a recorded hash do
not grant a license.

## Reconstructed Game Source

No license to Nintendo's original game code, graphics, music, characters, ROM
images, disk images, or FDS BIOS is granted by this repository. The assembly is
published as a reverse-engineering and preservation work; users are responsible
for obtaining required inputs lawfully and for complying with applicable law.
Original ROM/FDS/BIOS files and extracted proprietary assets are ignored and
must not be committed.

The project-specific source and documentation currently have no separate
repository-wide license grant. Their
presence in the repository does not by itself grant redistribution rights.

## Third-Party Material

- `ca65` and `ld65` are cc65 tools under the zlib license. Retrolarium Kit
  builds and ships them with the notice; this repository stores no
  executables. The binaries released with 2.1 and 2.2, their notice and
  provenance stay at those tags.
- Runtime movie provenance and its CC BY 2.0 source are recorded in
  `movies/README.md`.
- Referenced editors and research sources are evidence only. Their license
  status is recorded where they are cited and their code is not imported unless
  an explicit provenance record says otherwise.

## Release Rule

Every new imported tool, fixture, data table, image, or other third-party file
must record its origin, applicable license or explicit `license_not_granted`
status, and a stable hash when byte identity matters. These records do not
make a legal determination.
