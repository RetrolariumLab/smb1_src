# Super Mario Bros.: build the source back into the original images and check
# it. `make help` lists the targets; the recipes live under mk/.
PYTHON ?= python
# The kit command that names cc65 (rltool build-tools path nes ca65).
RLTOOL ?= rltool
export RLTOOL
# MAME for `make test-full` and `make golden`.
MAME ?= $(RETROLARIUM_MAME)
PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TAS_CHECK ?= $(PROJECT_DIR)movies/smb1_any_percent.check.json

.DEFAULT_GOAL := build

.PHONY: help build verify verify-all build-prg verify-prg build-hack verify-hack \
	build-expanded verify-expanded split-revision-assets build-revision verify-revision \
	verify-revisions split-platform-assets build-platform verify-platform verify-platforms \
	split-smb2-assets build-smb2-identity verify-smb2-identity build-smb2-source \
	verify-smb2-source build-smb2 verify-smb2 test-smb2-relocation \
	prepare-ann-supplemental-assets build-ann-payloads build-ann-supplemental-courses \
	build-ann-ending build-ann-hard-courses verify-ann-audio verify-ann-tail-core \
	verify-ann-supplemental-courses verify-ann-ending verify-ann-hard-courses \
	test-relocation test-relocation-revisions test-platform-relocations \
	test-ann-main-relocation split split-all check-assets studio-check lint format test \
	test-full golden hooks clean _require-assets

include mk/core.mk
include mk/smb2.mk
include mk/relocation.mk
include mk/variants.mk
include mk/profiles.mk

# Open every revision of super_mario_bros.rlj in a throwaway copy of the
# repository the way Retrolarium Studio does, and rebuild each without edits.
studio-check:
	$(RLTOOL) studio check "$(PROJECT_DIR)super_mario_bros.rlj"

# The quick suite: the unit tests, every image byte for byte against the ones
# that are here, the variants, the relocated JU build and the studio check.
test:
	$(PYTHON) -m unittest discover -s "$(PROJECT_DIR)tests" -t "$(PROJECT_DIR)" -p "test_*.py"
	$(MAKE) --no-print-directory verify-all verify-smb2 verify-hack verify-expanded \
		verify-ann-supplemental-courses verify-ann-ending verify-ann-hard-courses \
		test-relocation studio-check

# The full suite: the quick one, then the any% TAS in MAME on the relocated JU
# build and on the CNROM build, compared with what the original ROM gives
# (movies/smb1_any_percent.check.json, written by `make golden`).
test-full: test
	$(RLTOOL) movie check "$(TAS_CHECK)" --rom "$(RELOCATION_ROM)" --mame "$(MAME)"
	$(RLTOOL) movie check "$(TAS_CHECK)" --rom "$(EXPANDED_BUILD_DIR)/smb.nes" --mame "$(MAME)"

# What the original ROM gives at the TAS's checkpoints.
golden:
	$(RLTOOL) movie golden "$(TAS_CHECK)" --rom "$(ORIGINAL_ROM)" --mame "$(MAME)"

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
	@echo "  make build-hack / verify-hack, build-expanded / verify-expanded   the variants"
	@echo "  make build-ann-payloads       the All Night Nippon courses and ending"
	@echo "  make test-relocation          every module moved (RELOCATION_PROFILE=ju|...)"
	@echo "  make studio-check             open and rebuild every super_mario_bros.rlj revision"
	@echo "  make test                     the quick suite"
	@echo "  make test-full                test, then the TAS in MAME (MAME=<path>)"
	@echo "  make golden                   record the TAS's checkpoints from the original"
	@echo "  make lint / format            the house style (Retrolarium Kit)"
	@echo "  make hooks                    install the Git hooks"
	@echo "  make clean                    remove the build output"
