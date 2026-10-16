# Super Mario Bros.: build the source back into the original images and check
# it. `make help` lists the targets.
PYTHON ?= python
# The kit command that names cc65 (rltool build-tools path nes ca65).
RLTOOL ?= rltool
export RLTOOL
# MAME for `make test-full` and `make golden`.
MAME ?= $(RETROLARIUM_MAME)
RUN := $(PYTHON) scripts/run.py

# The private assets: assets/manifest.json names the ROMs and disks and what
# `make split` cuts out of them into assets/generated/; `rltool assets`
# (Retrolarium Kit) splits, checks and verifies. Every revision builds from
# the JU assets and its own.
ASSETS = $(RLTOOL) assets $(1)
BASE_IMAGE := ju
GENERATED := assets/generated
ORIGINAL_ROM ?= Super Mario Bros. (JU) [!].nes
NATIVE_CFG := config/linker/nrom256_prg_only.cfg
FDS_CFG := config/linker/fds_prg.cfg
NATIVE_DIR := build/native

# The revisions: the image ids of assets/manifest.json (REVISION=<id>).
REVISION ?= pal
REVISION_DIR = build/revisions/$(REVISION)
FDS_REVISIONS := fds_smb ann_fds smb2_jp_fds
REVISION_ROM = $(REVISION_DIR)/$(if $(filter $(REVISION),$(FDS_REVISIONS)),smb.fds,smb.nes)
SOURCE_ju := src/revisions/ju.asm
SOURCE_pal := src/revisions/pal.asm
SOURCE_pc10 := src/revisions/pc10.asm
SOURCE_vs_smb := src/revisions/vs.asm
SOURCE_fds_smb := src/revisions/fds_smb.asm
SOURCE_ann_fds := src/revisions/ann/main.asm
# The cartridges: header, CHR and what follows it (the PlayChoice-10
# instruction ROM).
HEADER = $(if $(filter vs_smb,$(REVISION)),$(GENERATED)/platforms/vs_smb/header.bin,$(GENERATED)/header/smb.hdr)
CHR = $(if $(filter vs_smb,$(REVISION)),$(GENERATED)/platforms/vs_smb/chr.bin,$(GENERATED)/chr/smb.chr)
EXTRA_pc10 := $(GENERATED)/revisions/pc10/platform.extra
# The disks: the side from the disk image, and the disk files (by ID) each
# built program fills.
ANN_ASSETS := $(GENERATED)/platforms/ann_fds/source
ANN_DIR := build/revisions/ann_fds
FILES_fds_smb = 3,4=$(REVISION_DIR)/smb.prg
FILES_ann_fds = 5=$(REVISION_DIR)/smb.prg 32=$(ANN_DIR)/supplemental_courses/payload.bin \
	48=$(ANN_DIR)/ending/payload.bin 64=$(ANN_DIR)/hard_courses/payload.bin
FILES_smb2_jp_fds = 5=$(REVISION_DIR)/SM2MAIN.bin 32=$(REVISION_DIR)/SM2DATA2.bin \
	48=$(REVISION_DIR)/SM2DATA3.bin 64=$(REVISION_DIR)/SM2DATA4.bin
# What a revision builds first: the All Night Nippon disk's three overlays,
# and Super Mario Bros. 2's four program files from their own source.
BEFORE_ann_fds := build-ann-payloads
BEFORE_smb2_jp_fds := build-smb2-source

# The JU revision with its code moved (scripts/build/relocate.py).
RELOCATED_ROM := build/relocated/smb.nes
# The movies test-full plays, in this order: the TAS first, then a longplay.
MOVIE_CHECKS := movies/smb1_any_percent.check.json

.DEFAULT_GOAL := build

.PHONY: help build verify build-revision verify-revision verify-revisions split \
	_require-assets build-ann-payloads build-smb2-source build-relocated studio-check \
	lint format test test-full golden hooks clean

split:
	$(call ASSETS,split)

_require-assets:
	$(call ASSETS,check) --image $(BASE_IMAGE)

build: _require-assets
	$(RUN) build.build_native --source src/main.asm --config $(NATIVE_CFG) \
		--output-dir $(NATIVE_DIR) --header $(GENERATED)/header/smb.hdr --chr $(GENERATED)/chr/smb.chr

verify: build
	$(call ASSETS,verify) --image $(BASE_IMAGE) --built "$(NATIVE_DIR)/smb.nes"

# One revision (REVISION=<id>).
build-revision: $(BEFORE_$(REVISION))
	$(call ASSETS,check) --image $(BASE_IMAGE) --image $(REVISION)
ifneq ($(SOURCE_$(REVISION)),)
ifeq ($(filter $(REVISION),$(FDS_REVISIONS)),)
	$(RUN) build.build_native --source $(SOURCE_$(REVISION)) --config $(NATIVE_CFG) \
		--output-dir $(REVISION_DIR) --header $(HEADER) --chr $(CHR) \
		$(if $(EXTRA_$(REVISION)),--extra $(EXTRA_$(REVISION)))
else
	$(RUN) build.build_native --source $(SOURCE_$(REVISION)) --config $(FDS_CFG) \
		--output-dir $(REVISION_DIR) $(if $(filter ann_fds,$(REVISION)),--bin-include-dir $(ANN_ASSETS))
endif
endif
ifneq ($(filter $(REVISION),$(FDS_REVISIONS)),)
	$(RUN) build.fds_image --disk $(GENERATED)/platforms/$(REVISION)/disk.fds \
		$(foreach file,$(FILES_$(REVISION)),--file $(file)) --output $(REVISION_ROM)
endif

verify-revision: build-revision
	$(call ASSETS,verify) --image $(REVISION) --built "$(REVISION_ROM)"

# Every revision whose ROM or disk is here.
verify-revisions:
	@for revision in $$($(call ASSETS,images) --present); do \
		$(MAKE) --no-print-directory verify-revision REVISION=$$revision || exit 1; \
	done

# The All Night Nippon overlays: $(call ann_overlay,<name>)
ann_overlay = $(RUN) build.build_asm_range --source src/revisions/ann/$(1).asm \
	--config config/linker/ann/$(1).cfg --bin-include-dir $(ANN_ASSETS) \
	--object $(ANN_DIR)/$(1)/payload.o --output $(ANN_DIR)/$(1)/payload.bin \
	--labels $(ANN_DIR)/$(1)/payload.lbl --map $(ANN_DIR)/$(1)/payload.map

build-ann-payloads:
	$(call ASSETS,check) --image ann_fds
	$(call ann_overlay,supplemental_courses)
	$(call ann_overlay,ending)
	$(call ann_overlay,hard_courses)

build-smb2-source:
	$(RUN) build.build_smb2_source --output-dir build/revisions/smb2_jp_fds

build-relocated: _require-assets
	$(RUN) build.relocate

# Open every revision of super_mario_bros.rlj in a throwaway copy of the
# repository the way Retrolarium Studio does, and rebuild each without edits.
studio-check:
	$(RLTOOL) studio check super_mario_bros.rlj

# House style (config/lint.json) from Retrolarium Kit.
lint:
	$(RLTOOL) lint

format:
	$(RLTOOL) lint --fix

# The quick suite: the unit tests, every revision byte for byte whose image
# is here, the relocated JU build and the studio check.
test:
	$(PYTHON) -m unittest discover -s tests -t . -p "test_*.py"
	$(MAKE) --no-print-directory verify verify-revisions build-relocated studio-check

# The full suite: the quick one, then the movies in MAME on the relocated JU
# build in turn (the first that differs stops it), compared with what the
# original ROM gives (movies/*.check.json, written by `make golden`).
test-full: test
	$(RLTOOL) movie check $(MOVIE_CHECKS) --rom "$(RELOCATED_ROM)" --mame "$(MAME)"

golden:
	$(RLTOOL) movie golden $(MOVIE_CHECKS) --rom "$(ORIGINAL_ROM)" --mame "$(MAME)"

# `make hooks`, once per clone, makes Git check every commit and push for stop
# words and run `make lint` first (Retrolarium Kit's rltool hooks; the
# stop-word list lives outside the repositories).
hooks:
	$(RLTOOL) hooks install --project .

clean:
	$(PYTHON) -c "import shutil; shutil.rmtree('build', ignore_errors=True)"

help:
	@echo "Super Mario Bros. source reconstruction"
	@echo "  make split                  cut the assets out of the ROMs and disks that are here (once)"
	@echo "  make build / verify         the JU ROM / and byte for byte"
	@echo "  make build-revision REVISION=<id> / verify-revision / verify-revisions"
	@echo "                              ju pal pc10 vs_smb fds_smb ann_fds smb2_jp_fds"
	@echo "  make build-relocated        the JU revision with its code moved"
	@echo "  make studio-check           open and rebuild every super_mario_bros.rlj revision"
	@echo "  make test                   the quick suite"
	@echo "  make test-full              test, then the movies in MAME (MAME=<path>)"
	@echo "  make golden                 record the movies' checkpoints from the original"
	@echo "  make lint / format          the house style (Retrolarium Kit)"
	@echo "  make hooks                  install the Git hooks"
	@echo "  make clean                  remove the build output"
