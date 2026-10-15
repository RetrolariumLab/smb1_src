# Later-engine analysis and the independent SMB2 reconstruction.
SMB2_RECONSTRUCTION_MANIFEST ?= $(PROJECT_DIR)config/reconstruction/smb2.json
SMB2_PLATFORM_MANIFEST ?= $(PROJECT_DIR)config/smb2_platform_profile.json
SMB2_REFERENCE ?= $(PROJECT_DIR)Super Mario Brothers 2 (Japan).fds
SMB2_ASSET_DIR ?= $(GENERATED_ASSET_DIR)/smb2
SMB2_BUILD_DIR ?= $(PROJECT_DIR)build/smb2/identity
SMB2_IDENTITY_IMAGE ?= $(SMB2_BUILD_DIR)/smb2.fds
SMB2_SOURCE_BUILD_DIR ?= $(PROJECT_DIR)build/smb2/source
SMB2_SOURCE_IMAGE ?= $(SMB2_SOURCE_BUILD_DIR)/smb2.fds
SMB2_OVERLAY_RESULT_DIR ?= $(SMB2_SOURCE_BUILD_DIR)/overlay_runtime
SMB2_GAMEPLAY_RESULT_DIR ?= $(SMB2_SOURCE_BUILD_DIR)/gameplay_runtime
SMB2_RELOCATION_MANIFEST ?= $(PROJECT_DIR)config/relocation/smb2_jp_fds.json
SMB2_RELOCATION_BUILD_DIR ?= $(PROJECT_DIR)build/relocation/smb2_jp_fds/candidate
SMB2_RELOCATION_IMAGE ?= $(SMB2_RELOCATION_BUILD_DIR)/smb2.fds
SMB2_RELOCATION_SUMMARY ?= $(SMB2_RELOCATION_BUILD_DIR)/relocation_summary.json
SMB2_RELOCATION_OVERLAY_RESULT_DIR ?= $(SMB2_RELOCATION_BUILD_DIR)/overlay_runtime
SMB2_RELOCATION_GAMEPLAY_RESULT_DIR ?= $(SMB2_RELOCATION_BUILD_DIR)/gameplay_runtime
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

test-smb2-relocation: verify-smb2
	$(PYTHON) "$(PROJECT_DIR)scripts/run.py" validation.smb2_relocation_test \
		--project-root "$(PROJECT_DIR)" \
		--manifest "$(SMB2_RELOCATION_MANIFEST)" \
		--baseline-dir "$(SMB2_SOURCE_BUILD_DIR)" \
		--original-image "$(SMB2_REFERENCE)"
