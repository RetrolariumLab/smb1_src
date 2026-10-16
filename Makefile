# Super Mario Bros.: build the source back into the original images and check
# it. `make help` lists the targets.
PYTHON ?= python
# The kit command that names cc65 (rltool build-tools path nes ca65).
RLTOOL ?= rltool
export RLTOOL
# MAME for `make test-full` and `make golden`.
MAME ?= $(RETROLARIUM_MAME)
PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
# The movies test-full plays, in this order: the TAS first, then a longplay.
MOVIE_CHECKS ?= $(PROJECT_DIR)movies/smb1_any_percent.check.json
# The JU revision with its code moved (scripts/build/relocate.py).
RELOCATED_ROM ?= $(PROJECT_DIR)build/relocated/smb.nes

.DEFAULT_GOAL := build

.PHONY: help build verify verify-all build-prg verify-prg \
	split-revision-assets build-revision verify-revision \
	verify-revisions split-platform-assets build-platform verify-platform verify-platforms \
	split-smb2-assets build-smb2-identity verify-smb2-identity build-smb2-source \
	verify-smb2-source build-smb2 verify-smb2 \
	prepare-ann-supplemental-assets build-ann-payloads build-ann-supplemental-courses \
	build-ann-ending build-ann-hard-courses verify-ann-audio verify-ann-tail-core \
	verify-ann-supplemental-courses verify-ann-ending verify-ann-hard-courses \
	build-relocated split split-all check-assets studio-check lint format test \
	test-full golden hooks clean _require-assets

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
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.run_make_matrix \
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

_require-assets:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.check_assets \
		--manifest "$(ASSET_MANIFEST)" \
		--asset-dir "$(GENERATED_ASSET_DIR)"

clean:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.clean_artifacts \
		--project-root "$(PROJECT_DIR)" \
		--path "$(NATIVE_BUILD_DIR)"

# The revisions (PROFILE=ju|pc10|pal) and the platforms
# (PLATFORM=vs_smb|fds_smb|ann_fds) of config/revision_profiles.json and
# config/platform_profiles.json.
PROFILE ?= pc10
REVISION_MANIFEST ?= $(PROJECT_DIR)config/revision_profiles.json
REVISION_SOURCE ?= $(PROJECT_DIR)src/revisions/$(PROFILE).asm
REVISION_BUILD_DIR ?= $(PROJECT_DIR)build/revisions/$(PROFILE)
REVISION_OBJ ?= $(REVISION_BUILD_DIR)/smb.o
REVISION_PRG ?= $(REVISION_BUILD_DIR)/smb.prg
REVISION_LABELS ?= $(REVISION_BUILD_DIR)/smb.lbl
REVISION_MAP ?= $(REVISION_BUILD_DIR)/smb.map
REVISION_DEBUG ?= $(REVISION_BUILD_DIR)/smb.dbg
REVISION_ROM ?= $(REVISION_BUILD_DIR)/smb.nes
REVISION_ASSET_DIR ?= $(GENERATED_ASSET_DIR)/revisions
ifeq ($(PROFILE),pc10)
REVISION_REFERENCE ?= $(PROJECT_DIR)Super Mario Bros. (PC10).nes
else ifeq ($(PROFILE),ju)
REVISION_REFERENCE ?= $(PROJECT_DIR)Super Mario Bros. (JU) [!].nes
else ifeq ($(PROFILE),pal)
REVISION_REFERENCE ?= $(PROJECT_DIR)Super Mario Bros. (E) (REV0) [!p].nes
else
REVISION_REFERENCE ?= $(PROJECT_DIR)$(PROFILE).nes
endif
PLATFORM ?= vs_smb
PLATFORM_MANIFEST ?= $(PROJECT_DIR)config/platform_profiles.json
PLATFORM_ASSET_DIR ?= $(GENERATED_ASSET_DIR)/platforms
PLATFORM_BUILD_DIR ?= $(PROJECT_DIR)build/platforms/$(PLATFORM)
PLATFORM_OBJ ?= $(PLATFORM_BUILD_DIR)/smb.o
PLATFORM_PRG ?= $(PLATFORM_BUILD_DIR)/smb.prg
PLATFORM_LABELS ?= $(PLATFORM_BUILD_DIR)/smb.lbl
PLATFORM_MAP ?= $(PLATFORM_BUILD_DIR)/smb.map
PLATFORM_DEBUG ?= $(PLATFORM_BUILD_DIR)/smb.dbg
PLATFORM_BIN_INCLUDE_ARGS =
ifeq ($(PLATFORM),vs_smb)
PLATFORM_SOURCE ?= $(PROJECT_DIR)src/revisions/vs.asm
PLATFORM_CFG ?= $(NATIVE_CFG)
PLATFORM_REFERENCE ?= $(PROJECT_DIR)VS. Super Mario Bros. (VS).nes
PLATFORM_OUTPUT ?= $(PLATFORM_BUILD_DIR)/smb.nes
else ifeq ($(PLATFORM),fds_smb)
PLATFORM_SOURCE ?= $(PROJECT_DIR)src/revisions/fds_smb.asm
PLATFORM_CFG ?= $(PROJECT_DIR)config/linker/fds_prg.cfg
PLATFORM_REFERENCE ?= $(PROJECT_DIR)Super Mario Brothers (Japan).fds
PLATFORM_OUTPUT ?= $(PLATFORM_BUILD_DIR)/smb.fds
else ifeq ($(PLATFORM),ann_fds)
PLATFORM_SOURCE ?= $(PROJECT_DIR)src/revisions/ann/main.asm
PLATFORM_CFG ?= $(PROJECT_DIR)config/linker/fds_prg.cfg
PLATFORM_REFERENCE ?= $(PROJECT_DIR)All Night Nippon Super Mario Brothers (Japan) (Promotion Card).fds
PLATFORM_OUTPUT ?= $(PLATFORM_BUILD_DIR)/smb.fds
PLATFORM_BIN_INCLUDE_ARGS = --bin-include-dir "$(ANN_SUPPLEMENTAL_ASSET_DIR)"
PLATFORM_PAYLOAD_ARGS = \
	--payload NSMDATA2=$(ANN_SUPPLEMENTAL_COURSES_BUILD_DIR)/payload.bin \
	--payload NSMDATA3=$(ANN_ENDING_BUILD_DIR)/payload.bin \
	--payload NSMDATA4=$(ANN_HARD_COURSES_BUILD_DIR)/payload.bin
else
PLATFORM_SOURCE ?= $(PROJECT_DIR)src/platforms/$(PLATFORM).asm
PLATFORM_CFG ?= $(NATIVE_CFG)
PLATFORM_REFERENCE ?= $(PROJECT_DIR)$(PLATFORM)
PLATFORM_OUTPUT ?= $(PLATFORM_BUILD_DIR)/smb.nes
endif
split-revision-assets:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.revision_profiles split \
		--manifest "$(REVISION_MANIFEST)" \
		--profile "$(PROFILE)" \
		--reference-rom "$(REVISION_REFERENCE)" \
		--asset-dir "$(REVISION_ASSET_DIR)"

build-revision: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.build_native \
		--source "$(REVISION_SOURCE)" \
		--config "$(NATIVE_CFG)" \
		--manifest "$(ASSET_MANIFEST)" \
		--object "$(REVISION_OBJ)" \
		--prg "$(REVISION_PRG)" \
		--labels "$(REVISION_LABELS)" \
		--map "$(REVISION_MAP)" \
		--debug-info "$(REVISION_DEBUG)" \
		--output-rom "$(REVISION_ROM)" \
		--prg-only
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.revision_profiles build \
		--manifest "$(REVISION_MANIFEST)" \
		--profile "$(PROFILE)" \
		--asset-dir "$(REVISION_ASSET_DIR)" \
		--header "$(GENERATED_HEADER)" \
		--prg "$(REVISION_PRG)" \
		--chr "$(GENERATED_CHR)" \
		--output "$(REVISION_ROM)"

verify-revision: build-revision
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.revision_profiles verify \
		--manifest "$(REVISION_MANIFEST)" \
		--profile "$(PROFILE)" \
		--reference-rom "$(REVISION_REFERENCE)" \
		--asset-dir "$(REVISION_ASSET_DIR)" \
		--header "$(GENERATED_HEADER)" \
		--prg "$(REVISION_PRG)" \
		--chr "$(GENERATED_CHR)" \
		--output "$(REVISION_ROM)"

verify-revisions:
	$(MAKE) verify-revision PROFILE=ju
	$(MAKE) verify-revision PROFILE=pc10
	$(MAKE) verify-revision PROFILE=pal

ifeq ($(PLATFORM),ann_fds)
build-platform: build-ann-payloads
endif

build-platform:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.build_native \
		--source "$(PLATFORM_SOURCE)" \
		--config "$(PLATFORM_CFG)" \
		--manifest "$(ASSET_MANIFEST)" \
		--object "$(PLATFORM_OBJ)" \
		--prg "$(PLATFORM_PRG)" \
		--labels "$(PLATFORM_LABELS)" \
		--map "$(PLATFORM_MAP)" \
		--debug-info "$(PLATFORM_DEBUG)" \
		--output-rom "$(PLATFORM_OUTPUT)" \
		$(PLATFORM_BIN_INCLUDE_ARGS) \
		--prg-only
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.platform_profiles build \
		--manifest "$(PLATFORM_MANIFEST)" \
		--profile "$(PLATFORM)" \
		--asset-dir "$(PLATFORM_ASSET_DIR)" \
		--prg "$(PLATFORM_PRG)" \
		$(PLATFORM_PAYLOAD_ARGS) \
		--output "$(PLATFORM_OUTPUT)"

verify-platform: build-platform
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.platform_profiles verify \
		--manifest "$(PLATFORM_MANIFEST)" \
		--profile "$(PLATFORM)" \
		--reference "$(PLATFORM_REFERENCE)" \
		--asset-dir "$(PLATFORM_ASSET_DIR)" \
		--prg "$(PLATFORM_PRG)" \
		$(PLATFORM_PAYLOAD_ARGS) \
		--output "$(PLATFORM_OUTPUT)"

verify-platforms:
	$(MAKE) verify-platform PLATFORM=vs_smb
	$(MAKE) verify-platform PLATFORM=fds_smb
	$(MAKE) verify-platform PLATFORM=ann_fds

verify-all:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.run_make_matrix \
		--project-dir "$(PROJECT_DIR)" \
		--make "$(MAKE)" \
		--title "ROM verification matrix" \
		--step "verify" \
		--step "verify-revision PROFILE=ju" \
		--step "verify-revision PROFILE=pc10" \
		--step "verify-revision PROFILE=pal" \
		--step "verify-platform PLATFORM=vs_smb" \
		--step "verify-platform PLATFORM=fds_smb" \
		--step "verify-platform PLATFORM=ann_fds"

# Super Mario Bros. 2 (Japan), rebuilt from its own source.
SMB2_RECONSTRUCTION_MANIFEST ?= $(PROJECT_DIR)config/reconstruction/smb2.json
SMB2_PLATFORM_MANIFEST ?= $(PROJECT_DIR)config/smb2_platform_profile.json
SMB2_REFERENCE ?= $(PROJECT_DIR)Super Mario Brothers 2 (Japan).fds
SMB2_ASSET_DIR ?= $(GENERATED_ASSET_DIR)/smb2
SMB2_BUILD_DIR ?= $(PROJECT_DIR)build/smb2/identity
SMB2_IDENTITY_IMAGE ?= $(SMB2_BUILD_DIR)/smb2.fds
SMB2_SOURCE_BUILD_DIR ?= $(PROJECT_DIR)build/smb2/source
SMB2_SOURCE_IMAGE ?= $(SMB2_SOURCE_BUILD_DIR)/smb2.fds
split-platform-assets:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.platform_profiles split \
		--manifest "$(PLATFORM_MANIFEST)" \
		--profile "$(PLATFORM)" \
		--reference "$(PLATFORM_REFERENCE)" \
		--asset-dir "$(PLATFORM_ASSET_DIR)"

split-smb2-assets:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.platform_profiles split \
		--manifest "$(SMB2_PLATFORM_MANIFEST)" \
		--profile smb2_jp_fds \
		--reference "$(SMB2_REFERENCE)" \
		--asset-dir "$(SMB2_ASSET_DIR)" \
		--retain-primary

build-smb2-identity:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.platform_profiles build \
		--manifest "$(SMB2_PLATFORM_MANIFEST)" \
		--profile smb2_jp_fds \
		--asset-dir "$(SMB2_ASSET_DIR)" \
		--output "$(SMB2_IDENTITY_IMAGE)"

verify-smb2-identity: build-smb2-identity
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.platform_profiles verify \
		--manifest "$(SMB2_PLATFORM_MANIFEST)" \
		--profile smb2_jp_fds \
		--reference "$(SMB2_REFERENCE)" \
		--asset-dir "$(SMB2_ASSET_DIR)" \
		--output "$(SMB2_IDENTITY_IMAGE)"

build-smb2-source:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.build_smb2_source \
		--manifest "$(SMB2_RECONSTRUCTION_MANIFEST)" \
		--output-dir "$(SMB2_SOURCE_BUILD_DIR)"

verify-smb2-source:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.build_smb2_source \
		--manifest "$(SMB2_RECONSTRUCTION_MANIFEST)" \
		--output-dir "$(SMB2_SOURCE_BUILD_DIR)" \
		--verify

build-smb2: build-smb2-source
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.platform_profiles build \
		--manifest "$(SMB2_PLATFORM_MANIFEST)" \
		--profile smb2_jp_fds \
		--asset-dir "$(SMB2_ASSET_DIR)" \
		--prg "$(SMB2_SOURCE_BUILD_DIR)/SM2MAIN.bin" \
		--payload "SM2DATA2=$(SMB2_SOURCE_BUILD_DIR)/SM2DATA2.bin" \
		--payload "SM2DATA3=$(SMB2_SOURCE_BUILD_DIR)/SM2DATA3.bin" \
		--payload "SM2DATA4=$(SMB2_SOURCE_BUILD_DIR)/SM2DATA4.bin" \
		--output "$(SMB2_SOURCE_IMAGE)"

verify-smb2: verify-smb2-source
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.platform_profiles verify \
		--manifest "$(SMB2_PLATFORM_MANIFEST)" \
		--profile smb2_jp_fds \
		--reference "$(SMB2_REFERENCE)" \
		--asset-dir "$(SMB2_ASSET_DIR)" \
		--prg "$(SMB2_SOURCE_BUILD_DIR)/SM2MAIN.bin" \
		--payload "SM2DATA2=$(SMB2_SOURCE_BUILD_DIR)/SM2DATA2.bin" \
		--payload "SM2DATA3=$(SMB2_SOURCE_BUILD_DIR)/SM2DATA3.bin" \
		--payload "SM2DATA4=$(SMB2_SOURCE_BUILD_DIR)/SM2DATA4.bin" \
		--output "$(SMB2_SOURCE_IMAGE)"

# The All Night Nippon payloads.
ANN_REFERENCE ?= $(PROJECT_DIR)All Night Nippon Super Mario Brothers (Japan) (Promotion Card).fds
ANN_TAIL_BUILD_DIR ?= $(PROJECT_DIR)build/platforms/ann_tail
ANN_TAIL_CORE_SOURCE ?= $(PROJECT_DIR)src/revisions/ann/tail_core.asm
ANN_TAIL_CORE_CFG ?= $(PROJECT_DIR)config/linker/ann/tail_core.cfg
ANN_AUDIO_SOURCE ?= $(PROJECT_DIR)src/revisions/ann/audio_tail.asm
ANN_AUDIO_CFG ?= $(PROJECT_DIR)config/linker/ann/audio_tail.cfg
ANN_AUDIO_BUILD_DIR ?= $(PROJECT_DIR)build/platforms/ann_audio
ANN_SUPPLEMENTAL_COURSES_SOURCE ?= $(PROJECT_DIR)src/revisions/ann/supplemental_courses.asm
ANN_SUPPLEMENTAL_COURSES_CFG ?= $(PROJECT_DIR)config/linker/ann/supplemental_courses.cfg
ANN_SUPPLEMENTAL_COURSES_BUILD_DIR ?= $(PROJECT_DIR)build/platforms/ann_supplemental_courses
ANN_SUPPLEMENTAL_ASSET_DIR ?= $(PROJECT_DIR)assets/generated/platforms/ann_fds/source
ANN_ENDING_SOURCE ?= $(PROJECT_DIR)src/revisions/ann/ending.asm
ANN_ENDING_CFG ?= $(PROJECT_DIR)config/linker/ann/ending.cfg
ANN_ENDING_BUILD_DIR ?= $(PROJECT_DIR)build/platforms/ann_ending
ANN_HARD_COURSES_SOURCE ?= $(PROJECT_DIR)src/revisions/ann/hard_courses.asm
ANN_HARD_COURSES_CFG ?= $(PROJECT_DIR)config/linker/ann/hard_courses.cfg
ANN_HARD_COURSES_BUILD_DIR ?= $(PROJECT_DIR)build/platforms/ann_hard_courses
verify-ann-audio: prepare-ann-supplemental-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.build_asm_range \
		--source "$(ANN_AUDIO_SOURCE)" \
		--config "$(ANN_AUDIO_CFG)" \
		--bin-include-dir "$(ANN_SUPPLEMENTAL_ASSET_DIR)" \
		--object "$(ANN_AUDIO_BUILD_DIR)/audio.o" \
		--output "$(ANN_AUDIO_BUILD_DIR)/audio.bin" \
		--labels "$(ANN_AUDIO_BUILD_DIR)/audio.lbl" \
		--map "$(ANN_AUDIO_BUILD_DIR)/audio.map"
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.verify_platform_range \
		--manifest "$(PLATFORM_MANIFEST)" \
		--profile ann_fds \
		--reference "$(ANN_REFERENCE)" \
		--candidate "$(ANN_AUDIO_BUILD_DIR)/audio.bin" \
		--load-address 0x6000 \
		--start 0xD2E4 \
		--end 0xDFFA

verify-ann-tail-core: prepare-ann-supplemental-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.build_asm_range \
		--source "$(ANN_TAIL_CORE_SOURCE)" \
		--config "$(ANN_TAIL_CORE_CFG)" \
		--bin-include-dir "$(ANN_SUPPLEMENTAL_ASSET_DIR)" \
		--object "$(ANN_TAIL_BUILD_DIR)/core.o" \
		--output "$(ANN_TAIL_BUILD_DIR)/core.bin" \
		--labels "$(ANN_TAIL_BUILD_DIR)/core.lbl" \
		--map "$(ANN_TAIL_BUILD_DIR)/core.map"
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.verify_platform_range \
		--manifest "$(PLATFORM_MANIFEST)" \
		--profile ann_fds \
		--reference "$(ANN_REFERENCE)" \
		--candidate "$(ANN_TAIL_BUILD_DIR)/core.bin" \
		--load-address 0x6000 \
		--start 0xBFBF \
		--end 0xE000

build-ann-payloads: build-ann-supplemental-courses build-ann-ending build-ann-hard-courses

prepare-ann-supplemental-assets:
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.prepare_ann_supplemental \
		--manifest "$(PLATFORM_MANIFEST)" \
		--profile ann_fds \
		--reference "$(ANN_REFERENCE)" \
		--output-dir "$(ANN_SUPPLEMENTAL_ASSET_DIR)"

build-ann-supplemental-courses: prepare-ann-supplemental-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.build_asm_range \
		--source "$(ANN_SUPPLEMENTAL_COURSES_SOURCE)" \
		--config "$(ANN_SUPPLEMENTAL_COURSES_CFG)" \
		--bin-include-dir "$(ANN_SUPPLEMENTAL_ASSET_DIR)" \
		--object "$(ANN_SUPPLEMENTAL_COURSES_BUILD_DIR)/payload.o" \
		--output "$(ANN_SUPPLEMENTAL_COURSES_BUILD_DIR)/payload.bin" \
		--labels "$(ANN_SUPPLEMENTAL_COURSES_BUILD_DIR)/payload.lbl" \
		--map "$(ANN_SUPPLEMENTAL_COURSES_BUILD_DIR)/payload.map"

verify-ann-supplemental-courses: build-ann-supplemental-courses
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.verify_platform_range \
		--manifest "$(PLATFORM_MANIFEST)" \
		--profile ann_fds \
		--reference "$(ANN_REFERENCE)" \
		--candidate "$(ANN_SUPPLEMENTAL_COURSES_BUILD_DIR)/payload.bin" \
		--payload NSMDATA2 \
		--load-address 0xC470 \
		--start 0xC470 \
		--end 0xD270

build-ann-ending: prepare-ann-supplemental-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.build_asm_range \
		--source "$(ANN_ENDING_SOURCE)" \
		--config "$(ANN_ENDING_CFG)" \
		--bin-include-dir "$(ANN_SUPPLEMENTAL_ASSET_DIR)" \
		--object "$(ANN_ENDING_BUILD_DIR)/payload.o" \
		--output "$(ANN_ENDING_BUILD_DIR)/payload.bin" \
		--labels "$(ANN_ENDING_BUILD_DIR)/payload.lbl" \
		--map "$(ANN_ENDING_BUILD_DIR)/payload.map"

verify-ann-ending: build-ann-ending
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.verify_platform_range \
		--manifest "$(PLATFORM_MANIFEST)" \
		--profile ann_fds \
		--reference "$(ANN_REFERENCE)" \
		--candidate "$(ANN_ENDING_BUILD_DIR)/payload.bin" \
		--payload NSMDATA3 \
		--load-address 0xC5D0 \
		--start 0xC5D0 \
		--end 0xD2E2

build-ann-hard-courses: prepare-ann-supplemental-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.build_asm_range \
		--source "$(ANN_HARD_COURSES_SOURCE)" \
		--config "$(ANN_HARD_COURSES_CFG)" \
		--bin-include-dir "$(ANN_SUPPLEMENTAL_ASSET_DIR)" \
		--object "$(ANN_HARD_COURSES_BUILD_DIR)/payload.o" \
		--output "$(ANN_HARD_COURSES_BUILD_DIR)/payload.bin" \
		--labels "$(ANN_HARD_COURSES_BUILD_DIR)/payload.lbl" \
		--map "$(ANN_HARD_COURSES_BUILD_DIR)/payload.map"

verify-ann-hard-courses: build-ann-hard-courses
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.verify_platform_range \
		--manifest "$(PLATFORM_MANIFEST)" \
		--profile ann_fds \
		--reference "$(ANN_REFERENCE)" \
		--candidate "$(ANN_HARD_COURSES_BUILD_DIR)/payload.bin" \
		--payload NSMDATA4 \
		--load-address 0xC296 \
		--start 0xC296 \
		--end 0xD086

build-relocated: _require-assets
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" build.relocate --original-rom "$(ORIGINAL_ROM)"

# Open every revision of super_mario_bros.rlj in a throwaway copy of the
# repository the way Retrolarium Studio does, and rebuild each without edits.
studio-check:
	$(RLTOOL) studio check "$(PROJECT_DIR)super_mario_bros.rlj"

# House style (config/lint.json) from Retrolarium Kit.
lint:
	$(RLTOOL) lint --project "$(PROJECT_DIR)."

format:
	$(RLTOOL) lint --project "$(PROJECT_DIR)." --fix

# The quick suite: the unit tests, every image byte for byte against the ones
# that are here, the relocated JU build and the studio check.
test:
	$(PYTHON) -m unittest discover -s "$(PROJECT_DIR)tests" -t "$(PROJECT_DIR)" -p "test_*.py"
	$(MAKE) --no-print-directory verify-all verify-smb2 \
		verify-ann-supplemental-courses verify-ann-ending verify-ann-hard-courses \
		build-relocated studio-check

# The full suite: the quick one, then the any% TAS in MAME on the relocated JU
# build, compared with what the original ROM gives
# (movies/smb1_any_percent.check.json, written by `make golden`).
test-full: test
	$(RLTOOL) movie check $(MOVIE_CHECKS) --rom "$(RELOCATED_ROM)" --mame "$(MAME)"

# What the original ROM gives at the TAS's checkpoints.
golden:
	$(RLTOOL) movie golden $(MOVIE_CHECKS) --rom "$(ORIGINAL_ROM)" --mame "$(MAME)"

# `make hooks`, once per clone, makes Git check every commit and push for stop
# words and run `make lint` first (Retrolarium Kit's rltool hooks; the
# stop-word list lives outside the repositories).
hooks:
	$(RLTOOL) hooks install --project .

help:
	@echo "Super Mario Bros. source reconstruction"
	@echo "  make split / split-all        unpack the assets from your ROMs (once)"
	@echo "  make build / verify           the JU ROM / and byte for byte"
	@echo "  make verify-revision PROFILE=pal|pc10, verify-platform PLATFORM=vs_smb|fds_smb|ann_fds"
	@echo "  make verify-all               every revision and platform whose image is here"
	@echo "  make build-smb2 / verify-smb2 Super Mario Bros. 2 (Japan)"
	@echo "  make build-ann-payloads       the All Night Nippon courses and ending"
	@echo "  make build-relocated          the JU revision with its code moved"
	@echo "  make studio-check             open and rebuild every super_mario_bros.rlj revision"
	@echo "  make test                     the quick suite"
	@echo "  make test-full                test, then the TAS in MAME (MAME=<path>)"
	@echo "  make golden                   record the TAS's checkpoints from the original"
	@echo "  make lint / format            the house style (Retrolarium Kit)"
	@echo "  make hooks                    install the Git hooks"
	@echo "  make clean                    remove the build output"
