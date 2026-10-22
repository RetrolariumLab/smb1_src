# Super Mario Bros.: build the source back into the original images and check
# it. `make` alone lists the targets. The ROMs and disks are yours: copy them
# next to this file under the names assets/manifest.json gives, then run
# `make split` once.
PYTHON ?= python
RLTOOL ?= rltool
export RLTOOL
# cc65 from Retrolarium Kit, which verifies it; asked once, when a recipe
# first needs it (the recipes' shell wants forward slashes).
CA65 ?= $(eval CA65 := $$(subst \,/,$$(shell $$(RLTOOL) build-tools path nes ca65)))$(CA65)
LD65 ?= $(eval LD65 := $$(subst \,/,$$(shell $$(RLTOOL) build-tools path nes ld65)))$(LD65)

BASE_IMAGE := ju
# The revisions, by image id of assets/manifest.json, and the entry file each
# builds from; REVISION picks one. Every revision also takes JU's assets.
REVISIONS := ju pal pc10 vs_smb fds_smb ann_fds smb2_jp_fds
ENTRY_ju := src/revisions/ju.asm
ENTRY_pal := src/revisions/pal.asm
ENTRY_pc10 := src/revisions/pc10.asm
ENTRY_vs_smb := src/revisions/vs.asm
ENTRY_fds_smb := src/revisions/fds_smb.asm
ENTRY_ann_fds := src/revisions/ann/build.asm
ENTRY_smb2_jp_fds := src/revisions/smb2/build.asm
REVISION ?= $(BASE_IMAGE)
OUT = build/revisions/$(REVISION)
# The disks: their sides take the built program files by disk file ID.
DISKS := fds_smb ann_fds smb2_jp_fds
FILES_fds_smb = 3,4=$(OUT)/smb.prg
FILES_ann_fds = 5=$(OUT)/smb.prg 32=$(OUT)/NSMDATA2.bin 48=$(OUT)/NSMDATA3.bin 64=$(OUT)/NSMDATA4.bin
FILES_smb2_jp_fds = 5=$(OUT)/SM2MAIN.bin 32=$(OUT)/SM2DATA2.bin 48=$(OUT)/SM2DATA3.bin 64=$(OUT)/SM2DATA4.bin
# The linker config of each kind of image.
LINKER_CONFIG = $(if $(filter fds_smb,$(REVISION)),config/linker/fds_prg.cfg,$(if $(filter ann_fds,$(REVISION)),config/linker/ann.cfg,$(if $(filter smb2_jp_fds,$(REVISION)),config/linker/smb2.cfg,config/linker/nrom256.cfg)))
NAME = $(if $(filter smb2_jp_fds,$(REVISION)),smb2,smb)
LINKED = $(OUT)/$(NAME).$(if $(filter $(REVISION),$(DISKS)),prg,nes)
IMAGE = $(OUT)/$(NAME).$(if $(filter $(REVISION),$(DISKS)),fds,nes)
RELOCATED_OUT := build/relocated
RELOCATED_ROM := $(RELOCATED_OUT)/smb.nes
# The revisions whose ROM or disk is here (assets/manifest.json names them).
PRESENT = $(filter $(REVISIONS),$(shell $(RLTOOL) assets images --present))
# The movies JU's relocated build plays in `make test-full`, by name
# (movies/<name>.check.json, written by `make golden`).
MOVIES := tas
MOVIE_CHECKS = $(foreach movie,$(MOVIES),movies/$(movie).check.json)
MAME_OPTION = $(if $(MAME),--mame "$(MAME)")

define newline


endef

# Assemble and link: $(call link,<entry>,<output folder>,<name>,<linker config>,<ca65 options>)
link = $(PYTHON) -c "from pathlib import Path; Path('$(2)').mkdir(parents=True, exist_ok=True)"$(newline)\
	$(CA65) -I src -I $(dir $(1)) --bin-include-dir assets/generated $(5) --debug-info -g \
		-o "$(2)/$(3).o" -l "$(2)/$(3).lst" "$(1)"$(newline)\
	$(LD65) -C $(4) -o "$(2)/$(3).$(if $(filter $(REVISION),$(DISKS)),prg,nes)" "$(2)/$(3).o" \
		-Ln "$(2)/$(3).lbl" -m "$(2)/$(3).map" --dbgfile "$(2)/$(3).dbg"

.PHONY: help split build verify verify-revisions build-relocated studio-check profile-check \
	lint format test test-full golden play hooks clean _revision
.DEFAULT_GOAL := help

split:
	$(RLTOOL) assets split

_revision:
	$(if $(filter $(REVISION),$(REVISIONS)),,$(error REVISION=$(REVISION) is not one of: $(REVISIONS)))
	$(RLTOOL) assets check --image $(BASE_IMAGE) --image $(REVISION)

# Every build assembles anew: it takes a second, and nothing it reads
# (source, linker config, assets) can be missed. A disk's program files then
# go into its side.
build: _revision
	$(call link,$(ENTRY_$(REVISION)),$(OUT),$(NAME),$(LINKER_CONFIG))
	$(if $(filter $(REVISION),$(DISKS)),$(RLTOOL) fds write --disk assets/generated/platforms/$(REVISION)/disk.fds \
		$(foreach file,$(FILES_$(REVISION)),--file $(file)) --output "$(IMAGE)")

verify: build
	$(RLTOOL) assets verify --image $(REVISION) --built "$(IMAGE)"

# Every revision whose ROM or disk is here, byte for byte.
verify-revisions:
	$(if $(PRESENT),,$(error none of the images of $(REVISIONS) is here: copy them beside this Makefile and make split))
	$(foreach revision,$(PRESENT),$(MAKE) --no-print-directory verify REVISION=$(revision)$(newline))

# JU with its code moved: the source's relocation probes (src/main.asm) and
# the relocated linker config, which keeps the audio tables and vectors put.
build-relocated:
	$(MAKE) --no-print-directory _revision REVISION=$(BASE_IMAGE)
	$(call link,$(ENTRY_ju),$(RELOCATED_OUT),smb,config/linker/nrom256_relocated.cfg,-D con_relocated=1)

# Open the revisions of super_mario_bros.rlj whose image is here in a
# throwaway copy of the repository the way Retrolarium Studio does, and
# rebuild each without edits.
studio-check:
	$(RLTOOL) studio check super_mario_bros.rlj --present

# The table places config/game_profile.json records, against the builds.
profile-check:
	$(RLTOOL) profile tables --check $(foreach revision,$(PRESENT),--revision $(revision))

lint:
	$(RLTOOL) lint

format:
	$(RLTOOL) lint --fix

# The quick suite: every revision here byte for byte, JU relocated, the
# profile's table places and the studio check.
test:
	$(MAKE) --no-print-directory verify-revisions
	$(MAKE) --no-print-directory build-relocated profile-check studio-check

# The full suite: the quick one, then the TAS in MAME on the relocated JU
# build, compared with what the original ROM gives (`make golden`).
test-full: test
	$(RLTOOL) movie check $(MOVIE_CHECKS) --rom "$(RELOCATED_ROM)" $(MAME_OPTION)

golden:
	$(RLTOOL) movie golden $(MOVIE_CHECKS) --rom "$(shell $(RLTOOL) assets path --image $(BASE_IMAGE))" $(MAME_OPTION)

# Watch a movie in a MAME window at the game's speed, on the relocated build
# or on ROM=<image>; once the window is closed, its cells are compared with
# the original's. In MAME, F10 lifts the speed limit and Insert fast-forwards.
#   make play [MOVIE=<name>] [ROM=<image>] [FRAMES=<frame>] [CLOSE=1]
# FRAMES closes MAME at that frame (only the start of the movie), CLOSE=1 when
# the movie ends (else it stays open to play on, the credits say).
MOVIE ?= $(firstword $(MOVIES))
PLAY_ROM = $(if $(filter command line,$(origin ROM)),$(ROM),$(RELOCATED_ROM))

play: $(if $(filter command line,$(origin ROM)),,build-relocated)
	$(if $(wildcard movies/$(MOVIE).check.json),,$(error unknown MOVIE "$(MOVIE)": movies/ has \
		$(basename $(basename $(notdir $(wildcard movies/*.check.json))))))
	$(RLTOOL) movie play movies/$(MOVIE).check.json --rom "$(PLAY_ROM)" $(MAME_OPTION) \
		$(if $(FRAMES),--stop-at $(FRAMES)) $(if $(CLOSE),--close)

# `make hooks`, once per clone, makes Git check every commit and push for stop
# words and run `make lint` first (Retrolarium Kit's rltool hooks; the
# stop-word list lives outside the repositories).
hooks:
	$(RLTOOL) hooks install --project .

clean:
	$(PYTHON) -c "import shutil; shutil.rmtree('build', ignore_errors=True)"

help:
	$(info Super Mario Bros. source reconstruction: $(REVISIONS), REVISION=$(BASE_IMAGE) unless given)
	$(info   make split                  cut the assets out of the ROMs and disks that are here, once)
	$(info   make build [REVISION=id]    build a revision into build/revisions/id/)
	$(info   make verify [REVISION=id]   build it and compare it with its image byte for byte)
	$(info   make verify-revisions       every revision whose image is here)
	$(info   make build-relocated        JU with its code moved)
	$(info   make test                   the quick suite)
	$(info   make test-full              test, then the TAS in MAME: MAME=path or the kit's)
	$(info   make golden                 record the movie's checkpoints from the original ROM)
	$(info   make play [MOVIE=name]      watch a movie in MAME; ROM=image for another build)
	$(info   make studio-check / profile-check / lint / format / hooks / clean)
	@exit 0
