# Ensure image name has been passed to Makefile
ifndef DOCKER_IMAGE_NAME
$(error missing required variable: DOCKER_IMAGE_NAME)
endif

# Logging function, muted when using the "s" flag when executing make
log = $(if $(filter s,$(MAKEFLAGS)),,$(call info,$(1)))

# Escape codes for colored output
cc_red=$(shell echo -e "\033[0;31m")
cc_green=$(shell echo -e "\033[0;32m")
cc_end=$(shell echo -e "\033[0m")

# Detect latest Git tag for image
BUILD_DATE := $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
BUILD_TAG := $(strip $(shell git describe --abbrev=0 --match "$(DOCKER_IMAGE_NAME)/*" --tags 2>&- || echo "$(DOCKER_IMAGE_NAME)/0.0.0"))
BUILD_TAG_DATE := $(strip $(shell git log --max-count=1 --format='%aI' "$(BUILD_TAG)" 2>&- || echo "<n/a>"))
BUILD_VERSION := $(subst $(DOCKER_IMAGE_NAME)/,,$(BUILD_TAG))
GIT_COMMIT := $(strip $(shell git rev-parse HEAD))
GIT_COMMIT_SHORT := $(strip $(shell git rev-parse --short HEAD))
GIT_COMMIT_DATE := $(strip $(shell git show --no-patch --format='%ct' "$(GIT_COMMIT)"))
IMAGE_MRC_ID := $(strip $(shell git log --max-count=1 --format='%H' ./))
IMAGE_MRC_TAG := $(strip $(shell git describe --abbrev=0 --match "$(DOCKER_IMAGE_NAME)/*" --tags --exact-match "$(IMAGE_MRC_ID)" 2>&- || echo "<n/a>"))
IMAGE_UPTODATE := $(if $(filter-out <n/a>,$(IMAGE_MRC_TAG)),yes,no)

# Declare build variables
DOCKER_REGISTRY := https://quay.io
DOCKER_IMAGE_PATH := quay.io/snapserv/$(DOCKER_IMAGE_NAME)
DOCKER_IMAGE_TAG := $(BUILD_VERSION)-$(GIT_COMMIT_DATE)-$(GIT_COMMIT_SHORT)
DOCKER_LABEL_VENDOR := SnapServ
DOCKER_LABEL_URL := https://snapserv.net
DOCKER_LABEL_VCS_URL := https://github.com/snapserv/infrastructure
DOCKER_BUILD_FLAGS ?=

# Declare options for goss testing
GOSS_FILES_PATH := ../
GOSS_FILES_STRATEGY := mount
GOSS_OPTS := --color --retry-timeout 60s --sleep 1s

# Use environment variables from goss.env during testing if present
GOSS_ENV_FILE := goss.env
ifeq (,$(wildcard $(GOSS_ENV_FILE)))
GOSS_ENV_FILE := /dev/null
endif

# Check if working directory is dirty
GIT_CLEAN_REPO_CHECK := $(strip $(shell git status --porcelain))
GIT_CLEAN_REPO_CHECK := $(if $(firstword $(GIT_CLEAN_REPO_CHECK)),no,yes)
ifneq ($(GIT_CLEAN_REPO_CHECK),yes)
DOCKER_IMAGE_TAG := $(DOCKER_IMAGE_TAG)-dirty
endif

# Mark as release if current commit matches build tag commit (skip in debug)
GIT_TAG_COMMIT := $(strip $(shell git rev-list "$(BUILD_TAG)" --max-count=1 2>&-))
ifneq ($(RELEASE_CHECK),)
ifeq ($(GIT_COMMIT),$(GIT_TAG_COMMIT))
$(call log,release build: current commit [$(GIT_COMMIT)] matches tag commit [$(GIT_TAG_COMMIT)])
RELEASE_GOAL_CHECK := yes
else
$(call log,test build: current commit [$(GIT_COMMIT)] does not match tag commit [$(GIT_TAG_COMMIT)])
RELEASE_GOAL_CHECK := no
endif
else
$(call log,test build: forced for commit [$(GIT_COMMIT)] due to RELEASE_CHECK being unset)
RELEASE_GOAL_CHECK := no
endif

# Handle special logic for release targets
ifeq ($(RELEASE_GOAL_CHECK),yes)
## Abort if working directory is dirty
ifneq ($(GIT_CLEAN_REPO_CHECK),yes)
$(error unable to build release: working directory is dirty)
endif

## Modify image tag to build version
DOCKER_IMAGE_TAG := $(subst $(DOCKER_IMAGE_NAME)/,,$(BUILD_VERSION))
endif

# Print information about current build task
$(call log,============================== $(DOCKER_IMAGE_NAME) ==============================)
$(call log,>> Build Identifier: $(BUILD_VERSION) @ $(BUILD_DATE))
$(call log,>> Git Commit: $(GIT_COMMIT) @ $(GIT_COMMIT_DATE))
$(call log,>> Docker Image: $(DOCKER_IMAGE_PATH):$(DOCKER_IMAGE_TAG))
$(call log,>> Docker Image MRC: $(IMAGE_MRC_ID) (Tag: $(IMAGE_MRC_TAG)))
$(call log,>> Flags: cleanRepo=$(GIT_CLEAN_REPO_CHECK) releaseGoal=$(RELEASE_GOAL_CHECK) upToDate=$(IMAGE_UPTODATE))
$(call log,)

# Combined targets
default: test
release: test push
test: lint build goss output

# Automated CI target (release or test)
ifeq ($(RELEASE_GOAL_CHECK),yes)
auto: release
else
auto: test
endif

# Build container image
build:
	docker build $(DOCKER_BUILD_FLAGS) \
		--label org.label-schema.name="$(DOCKER_IMAGE_NAME)" \
		--label org.label-schema.vendor="$(DOCKER_LABEL_VENDOR)" \
		--label org.label-schema.url="$(DOCKER_LABEL_URL)" \
		--label org.label-schema.vcs-url="$(DOCKER_LABEL_VCS_URL)" \
		--label org.label-schema.build-date="$(BUILD_DATE)" \
		--label org.label-schema.version="$(BUILD_VERSION)" \
		--label org.label-schema.vcs-ref="$(GIT_COMMIT)" \
		--label org.label-schema.schema-version="1.0" \
		--tag $(DOCKER_IMAGE_PATH):latest \
		--tag $(DOCKER_IMAGE_PATH):$(DOCKER_IMAGE_TAG) \
		./

# Lint dockerfile
lint:
	cat Dockerfile | docker run \
		-i --rm hadolint/hadolint hadolint - \
		--ignore DL3007 --ignore DL3018 --ignore SC1091

# Test container image with Goss
goss: build
	# Export environment variables for Goss
	$(eval export GOSS_FILES_PATH)
	$(eval export GOSS_FILES_STRATEGY)
	$(eval export GOSS_OPTS)

	# Run dgoss for testing docker images
	dgoss run -it --rm \
		--env-file "$(GOSS_ENV_FILE)" \
		--read-only --tmpfs /run --tmpfs /tmp \
		"$(DOCKER_IMAGE_PATH):$(DOCKER_IMAGE_TAG)"

# Login to registry
login:
	@echo "$(DOCKER_REGISTRY_PASSWORD)" | docker login \
		-u "$(DOCKER_REGISTRY_USERNAME)" --password-stdin "$(DOCKER_REGISTRY)"

# Push image to registry
push: login
	docker push $(DOCKER_IMAGE_PATH):$(DOCKER_IMAGE_TAG)
	docker push $(DOCKER_IMAGE_PATH):latest

# Output image name
output:
	@echo Docker Image: $(DOCKER_IMAGE_PATH):$(DOCKER_IMAGE_TAG)

# Check if image is up-to-date
check-update:
ifneq ($(IMAGE_UPTODATE),yes)
	@echo "$(cc_red)[NOK]$(cc_end) Image $(DOCKER_IMAGE_NAME) is outdated since $(BUILD_TAG_DATE) with version $(BUILD_VERSION)"
else
	@echo "$(cc_green)[OK]$(cc_end)  Image $(DOCKER_IMAGE_NAME) is up-to-date with version $(BUILD_VERSION)"
endif

# Update image tag if not already most recent
update: check-update
ifneq ($(IMAGE_UPTODATE),yes)
	@echo "Changelog since latest release:"; \
	git log --oneline "$(BUILD_TAG)..HEAD" ./ 2>&-; \
	read -p "Please enter new version number: " _version; \
	git tag "$(DOCKER_IMAGE_NAME)/$${_version}" "$(IMAGE_MRC_ID)"; \
	echo "Tagged $(IMAGE_MRC_ID) as $(DOCKER_IMAGE_NAME)/$${_version}"
endif

.PHONY: default release test build lint login push output update check-update auto
