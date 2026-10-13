# Versioned release manifests and aggregate gates.
RELEASE_MANIFEST ?= $(PROJECT_DIR)config/preservation_source_1_0.json
SOURCE_2_MANIFEST ?= $(PROJECT_DIR)config/source_reconstruction_2_0.json
SOURCE_2_1_MANIFEST ?= $(PROJECT_DIR)config/source_reconstruction_2_1.json
SOURCE_2_1_TOOLCHAIN_MANIFEST ?= $(PROJECT_DIR)config/release_toolchain_2_1.json
SOURCE_2_2_MANIFEST ?= $(PROJECT_DIR)config/source_reconstruction_2_2.json
SOURCE_2_2_TOOLCHAIN_MANIFEST ?= $(PROJECT_DIR)config/release_toolchain_2_2.json
SOURCE_3_MANIFEST ?= $(PROJECT_DIR)config/source_reconstruction_3_0.json

release-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.release_audit \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(RELEASE_MANIFEST)"

release-check:
	$(MAKE) lint
	$(MAKE) test
	$(MAKE) roundtrip-formats
	$(MAKE) verify
	$(MAKE) trace
	$(MAKE) release-audit

# The 2.0, 2.1 and 2.2 manifests describe the trees tagged
# source-reconstruction-2.0, -2.1 and -2.2, which still had the Tkinter
# studios that Source Reconstruction 3.0 retired. Their audits run there, with
# each tag's own Make targets, in a disposable clone (validation.tag_audit).
SOURCE_2_TAG ?= source-reconstruction-2.0
SOURCE_2_1_TAG ?= source-reconstruction-2.1
SOURCE_2_2_TAG ?= source-reconstruction-2.2
TAG_AUDIT = $(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.tag_audit

source-2-audit:
	$(TAG_AUDIT) --tag "$(SOURCE_2_TAG)" -- "$(MAKE)" source-2-audit

source-2-release-audit:
	$(TAG_AUDIT) --tag "$(SOURCE_2_TAG)" -- "$(MAKE)" source-2-release-audit

source-2-1-audit:
	$(TAG_AUDIT) --tag "$(SOURCE_2_1_TAG)" -- "$(MAKE)" source-2-1-audit

source-2-1-release-audit:
	$(TAG_AUDIT) --tag "$(SOURCE_2_1_TAG)" -- "$(MAKE)" source-2-1-release-audit

source-2-1-tag-audit:
	$(TAG_AUDIT) --tag "$(SOURCE_2_1_TAG)" -- "$(MAKE)" source-2-1-tag-audit \
		SOURCE_2_1_TAG_PHASE=post SOURCE_2_1_TAG_REMOTE_ARG=

source-2-2-audit:
	$(TAG_AUDIT) --tag "$(SOURCE_2_2_TAG)" -- "$(MAKE)" source-2-2-audit

source-2-2-release-audit:
	$(TAG_AUDIT) --tag "$(SOURCE_2_2_TAG)" -- "$(MAKE)" source-2-2-release-audit

source-2-2-tag-audit:
	$(TAG_AUDIT) --tag "$(SOURCE_2_2_TAG)" -- "$(MAKE)" source-2-2-tag-audit \
		SOURCE_2_2_TAG_PHASE=post SOURCE_2_2_TAG_REMOTE_ARG=

check-source-2-1-toolchain:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.check_release_toolchain \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_1_TOOLCHAIN_MANIFEST)" \
		--fceux "$(FCEUX_EXE)" \
		--fds-bios "$(FDS_BIOS)"

check-source-2-2-toolchain:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.check_release_toolchain \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_2_TOOLCHAIN_MANIFEST)" \
		--fceux "$(FCEUX_EXE)" \
		--fds-bios "$(FDS_BIOS)"

# The functional 2.x gates stay on HEAD: identity, runtime, relocation,
# semantic evidence and the SMB2 sibling, without the retired studios.
source-2-functional-check:
	$(MAKE) release-check
	$(MAKE) validate-hack
	$(MAKE) validate-expanded
	$(MAKE) validate-revisions
	$(MAKE) validate-platforms

source-2-1-functional-check:
	$(MAKE) check-source-2-1-toolchain
	$(MAKE) source-2-functional-check
	$(MAKE) validate-relocation-revisions
	$(MAKE) validate-relocation-platforms
	$(MAKE) semantic-evidence
	$(MAKE) later-engine-feasibility
	$(MAKE) validate-smb2-runtime
	$(MAKE) validate-smb2-overlays
	$(MAKE) validate-smb2-gameplay
	$(MAKE) validate-smb2-relocation

source-2-2-functional-check:
	$(MAKE) check-source-2-2-toolchain
	$(MAKE) source-2-1-functional-check

source-2-check: source-2-functional-check source-2-release-audit
source-2-1-check: source-2-1-functional-check source-2-1-release-audit
source-2-2-check: source-2-2-functional-check source-2-2-release-audit
source-2-minor-check: source-2-2-check

# Retrolarium: every revision of super_mario_bros.rlj opens in the kit and
# builds back to its ROM, in a throwaway copy of the repository.
studio-check:
	$(RLTOOL) studio check super_mario_bros.rlj

# Source Reconstruction 3.0: the functional 2.2 gate, then studio-check with
# the manifest's Retrolarium section checked against the descriptor and the
# running kit.
source-3-audit:
	$(RLTOOL) studio check super_mario_bros.rlj --release "$(SOURCE_3_MANIFEST)"

source-3-check:
	$(MAKE) source-2-2-functional-check
	$(MAKE) source-3-audit

scaffold-check:
	$(MAKE) lint
	$(MAKE) test
	$(MAKE) release-audit
	$(MAKE) source-2-audit
	$(MAKE) source-2-1-audit
	$(MAKE) source-2-2-audit
