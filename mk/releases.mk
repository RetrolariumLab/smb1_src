# Versioned release manifests and aggregate gates.
RELEASE_MANIFEST ?= $(PROJECT_DIR)config/preservation_source_1_0.json
SOURCE_2_MANIFEST ?= $(PROJECT_DIR)config/source_reconstruction_2_0.json
SOURCE_2_1_MANIFEST ?= $(PROJECT_DIR)config/source_reconstruction_2_1.json
SOURCE_2_1_TOOLCHAIN_MANIFEST ?= $(PROJECT_DIR)config/release_toolchain_2_1.json
SOURCE_2_1_TAG_PHASE ?= pre
SOURCE_2_1_TAG_REMOTE_ARG ?= --check-remote
SOURCE_2_2_MANIFEST ?= $(PROJECT_DIR)config/source_reconstruction_2_2.json
SOURCE_2_2_TOOLCHAIN_MANIFEST ?= $(PROJECT_DIR)config/release_toolchain_2_2.json
SOURCE_2_2_TAG_PHASE ?= pre
SOURCE_2_2_TAG_REMOTE_ARG ?= --check-remote
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

source-2-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.source_2_audit \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_MANIFEST)"

source-2-release-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.source_2_audit \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_MANIFEST)" \
		--require-ready

source-2-check:
	$(MAKE) release-check
	$(MAKE) validate-hack
	$(MAKE) validate-expanded
	$(MAKE) check-studios
	$(MAKE) validate-revisions
	$(MAKE) validate-platforms
	$(MAKE) source-2-release-audit

source-2-1-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.source_2_1_audit \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_1_MANIFEST)"

source-2-1-release-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.source_2_1_audit \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_1_MANIFEST)" \
		--require-ready

check-source-2-1-toolchain:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.check_release_toolchain \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_1_TOOLCHAIN_MANIFEST)" \
		--fceux "$(FCEUX_EXE)" \
		--fds-bios "$(FDS_BIOS)"

source-2-1-tag-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.source_2_1_audit \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_1_MANIFEST)" \
		--require-ready \
		--tag-phase "$(SOURCE_2_1_TAG_PHASE)" \
		$(SOURCE_2_1_TAG_REMOTE_ARG)

source-2-1-pre-tag:
	$(MAKE) source-2-1-check
	$(MAKE) source-2-1-tag-audit SOURCE_2_1_TAG_PHASE=pre SOURCE_2_1_TAG_REMOTE_ARG=--check-remote

source-2-1-post-tag:
	$(MAKE) source-2-1-check
	$(MAKE) source-2-1-tag-audit SOURCE_2_1_TAG_PHASE=post SOURCE_2_1_TAG_REMOTE_ARG=--check-remote

source-2-1-check:
	$(MAKE) check-source-2-1-toolchain
	$(MAKE) source-2-check
	$(MAKE) validate-relocation-revisions
	$(MAKE) validate-relocation-platforms
	$(MAKE) semantic-evidence
	$(MAKE) check-content-profiles
	$(MAKE) later-engine-feasibility
	$(MAKE) validate-smb2-runtime
	$(MAKE) validate-smb2-overlays
	$(MAKE) validate-smb2-gameplay
	$(MAKE) validate-smb2-relocation
	$(MAKE) source-2-1-release-audit

scaffold-check:
	$(MAKE) lint
	$(MAKE) test
	$(MAKE) release-audit
	$(MAKE) source-2-audit
	$(MAKE) source-2-1-audit
	$(MAKE) source-2-2-audit

source-2-2-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.source_2_2_audit \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_2_MANIFEST)"

source-2-2-release-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.source_2_2_audit \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_2_MANIFEST)" \
		--require-ready

check-source-2-2-toolchain:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.check_release_toolchain \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_2_TOOLCHAIN_MANIFEST)" \
		--fceux "$(FCEUX_EXE)" \
		--fds-bios "$(FDS_BIOS)"

source-2-2-tag-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.source_2_2_audit \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SOURCE_2_2_MANIFEST)" \
		--require-ready \
		--tag-phase "$(SOURCE_2_2_TAG_PHASE)" \
		$(SOURCE_2_2_TAG_REMOTE_ARG)

source-2-2-check:
	$(MAKE) check-source-2-2-toolchain
	$(MAKE) source-2-1-check
	$(MAKE) source-2-2-release-audit

source-2-minor-check: source-2-2-check

source-2-2-pre-tag:
	$(MAKE) source-2-2-check
	$(MAKE) source-2-2-tag-audit SOURCE_2_2_TAG_PHASE=pre SOURCE_2_2_TAG_REMOTE_ARG=--check-remote

source-2-2-post-tag:
	$(MAKE) source-2-2-check
	$(MAKE) source-2-2-tag-audit SOURCE_2_2_TAG_PHASE=post SOURCE_2_2_TAG_REMOTE_ARG=--check-remote

list-content-profiles:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" authoring.content_profiles list \
		--manifest "$(CONTENT_PROFILE_MANIFEST)"

content-profile-audit:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" authoring.content_profiles audit \
		--manifest "$(CONTENT_PROFILE_MANIFEST)"
