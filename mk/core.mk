# Canonical build, shared paths, assets, lint, tests, and cleanup.
ORIGINAL_ROM ?= $(PROJECT_DIR)Super Mario Bros. (JU) [!].nes
ASSET_MANIFEST ?= $(PROJECT_DIR)assets/manifest.json
GENERATED_ASSET_DIR ?= $(PROJECT_DIR)assets/generated
GENERATED_HEADER ?= $(GENERATED_ASSET_DIR)/header/smb.hdr
GENERATED_CHR ?= $(GENERATED_ASSET_DIR)/chr/smb.chr

NATIVE_SOURCE ?= $(PROJECT_DIR)src/main.asm
NATIVE_CFG ?= $(PROJECT_DIR)config/linker/nrom256_prg_only.cfg
NATIVE_BUILD_DIR ?= $(PROJECT_DIR)build/native
NATIVE_OBJ ?= $(NATIVE_BUILD_DIR)/smbdis.o
NATIVE_PRG ?= $(NATIVE_BUILD_DIR)/smb.prg
NATIVE_LABELS ?= $(NATIVE_BUILD_DIR)/smb.lbl
NATIVE_MAP ?= $(NATIVE_BUILD_DIR)/smb.map
NATIVE_DEBUG ?= $(NATIVE_BUILD_DIR)/smb.dbg
NATIVE_ROM ?= $(NATIVE_BUILD_DIR)/smb.nes

build: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.build_native \
		--source "$(NATIVE_SOURCE)" \
		--config "$(NATIVE_CFG)" \
		--manifest "$(ASSET_MANIFEST)" \
		--original-rom "$(ORIGINAL_ROM)" \
		--header "$(GENERATED_HEADER)" \
		--chr "$(GENERATED_CHR)" \
		--object "$(NATIVE_OBJ)" \
		--prg "$(NATIVE_PRG)" \
		--labels "$(NATIVE_LABELS)" \
		--map "$(NATIVE_MAP)" \
		--debug-info "$(NATIVE_DEBUG)" \
		--output-rom "$(NATIVE_ROM)"

verify: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.build_native \
		--source "$(NATIVE_SOURCE)" \
		--config "$(NATIVE_CFG)" \
		--manifest "$(ASSET_MANIFEST)" \
		--original-rom "$(ORIGINAL_ROM)" \
		--header "$(GENERATED_HEADER)" \
		--chr "$(GENERATED_CHR)" \
		--object "$(NATIVE_OBJ)" \
		--prg "$(NATIVE_PRG)" \
		--labels "$(NATIVE_LABELS)" \
		--map "$(NATIVE_MAP)" \
		--debug-info "$(NATIVE_DEBUG)" \
		--output-rom "$(NATIVE_ROM)" \
		--verify

build-prg:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.build_native \
		--source "$(NATIVE_SOURCE)" \
		--config "$(NATIVE_CFG)" \
		--manifest "$(ASSET_MANIFEST)" \
		--object "$(NATIVE_OBJ)" \
		--prg "$(NATIVE_PRG)" \
		--labels "$(NATIVE_LABELS)" \
		--map "$(NATIVE_MAP)" \
		--debug-info "$(NATIVE_DEBUG)" \
		--output-rom "$(NATIVE_ROM)" \
		--prg-only

verify-prg:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.build_native \
		--source "$(NATIVE_SOURCE)" \
		--config "$(NATIVE_CFG)" \
		--manifest "$(ASSET_MANIFEST)" \
		--object "$(NATIVE_OBJ)" \
		--prg "$(NATIVE_PRG)" \
		--labels "$(NATIVE_LABELS)" \
		--map "$(NATIVE_MAP)" \
		--debug-info "$(NATIVE_DEBUG)" \
		--output-rom "$(NATIVE_ROM)" \
		--prg-only --verify

split:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.split_assets \
		--rom "$(ORIGINAL_ROM)" \
		--manifest "$(ASSET_MANIFEST)" \
		--output-dir "$(GENERATED_ASSET_DIR)"

split-all:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.run_make_matrix \
		--project-dir "$(PROJECT_DIR)" \
		--make "$(MAKE)" \
		--title "ROM asset split matrix" \
		--step "split" \
		--step "split-revision-assets PROFILE=pc10" \
		--step "split-revision-assets PROFILE=pal" \
		--step "split-platform-assets PLATFORM=vs_smb" \
		--step "split-platform-assets PLATFORM=fds_smb" \
		--step "split-platform-assets PLATFORM=ann_fds"

check-assets:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.check_assets \
		--manifest "$(ASSET_MANIFEST)" \
		--asset-dir "$(GENERATED_ASSET_DIR)"

# House style (config/lint.json) from Retrolarium Kit.
lint:
	$(RLTOOL) lint --project "$(PROJECT_DIR)."

format:
	$(RLTOOL) lint --project "$(PROJECT_DIR)." --fix

_require-assets:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.check_assets \
		--manifest "$(ASSET_MANIFEST)" \
		--asset-dir "$(GENERATED_ASSET_DIR)"

clean:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.clean_artifacts \
		--project-root "$(PROJECT_DIR)" \
		--path "$(NATIVE_BUILD_DIR)"
