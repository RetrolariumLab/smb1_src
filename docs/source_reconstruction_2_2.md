# Source Reconstruction 2.2

Source Reconstruction 2.2 is a compatible repository-modernization release.
Its project version remains 2.2, while its quality boundary follows the 2.x
line: it strengthens structure, evidence ownership, reproducibility, and
release metadata without introducing a new game profile, platform ABI,
relocation model, or sibling engine.

The predecessor is the published `source-reconstruction-2.1` tag at commit
`974c6c6`. All seven accepted profiles, their byte-identical outputs, direct
runtime coverage, relocation proofs, authoring workflows, and SMB2 sibling
source are inherited unchanged. Original ROMs, FDS images, BIOS data, CHR, and
extracted payloads remain ignored private inputs.

## Modernization Delta

- The root Makefile is a short stable interface. Workflow implementation lives
  in bounded files under `mk/`.
- Authoring, debugger, linker, reconstruction, and release configuration have
  explicit owners under `config/`.
- Tests mirror the `scripts/` responsibility packages and use package-aware
  discovery so identical package names cannot shadow production modules.
- `make help` exposes the principal public commands, while a command-level test
  protects that interface.
- The public 2.2 manifest is self-contained and records predecessor, scope,
  complete delta, profiles, runtime coverage, toolchain, artifacts, licensing,
  layout decisions, and aggregate gates.
- Lint rejects Cyrillic in current tracked public text. The release audit also
  checks new commit language, authorship, nonempty trees, message structure,
  and monotonic author and committer dates.
- Repository-layout evidence records every intentionally short ASM module and
  reviews each Python tool above the project threshold.

## Repository and Evidence Boundaries

`config/reconstruction/repository_layout.json` owns the measurable layout
policy. Short entrypoints, fixed vectors, declaration interfaces, and proven
shared adapters remain small because merging them would obscure their ABI or
address boundary. Large Python tools retain one public command only when their
domain transaction is cohesive and lower-level codecs or models are already
separate.

The historical 2.1 manifest remains readable from its tag. The current tree
removes superseded review metadata, but published commits and tags are not
rewritten. This release does not claim that historical blobs were erased; it
ensures all new or changed public content is English and self-contained.

## Verification

The quick structure-only gate does not require private ROMs:

```bash
make scaffold-check
```

The full release gate first reruns the complete published 2.1 gate, including
the inherited Preservation 1.0 and Source 2.0 gates, then validates the 2.2
layout, language, history, metadata, and pinned toolchain:

```bash
make source-2-2-check
```

`make source-2-minor-check` is the compatibility alias for the same gate.
Before tagging, `make source-2-2-pre-tag` additionally requires a clean rewrite
branch, a nonempty final release commit, and absence of the future local tag.
After an annotated tag is published, `make source-2-2-post-tag` verifies its
message and peeled local/remote target.

The manifest remains `development` until the complete gate succeeds on the
final candidate tree. Promotion to `tag-ready` changes tracked release metadata
and is therefore a substantive final commit, never an empty milestone.
