# Ensure image name has been passed to Makefile
ifndef DOCKER_IMAGE_NAME
$(error missing required variable: DOCKER_IMAGE_NAME)
endif

# Detect latest Git tag for image
BUILD_DATE := $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
BUILD_TAG := $(strip $(shell git describe --abbrev=0 --match "$(DOCKER_IMAGE_NAME)/*" --tags 2>&- || echo "v0.0.0"))
BUILD_VERSION := $(subst $(DOCKER_IMAGE_NAME)/,,$(BUILD_TAG))
GIT_COMMIT := $(strip $(shell git rev-parse HEAD))
GIT_COMMIT_SHORT := $(strip $(shell git rev-parse --short HEAD))
GIT_COMMIT_DATE := $(strip $(shell git show --no-patch --format='%ct' "$(GIT_COMMIT)"))

# Declare build variables
DOCKER_REGISTRY := https://quay.io
DOCKER_IMAGE_PATH := quay.io/snapserv/$(DOCKER_IMAGE_NAME)
DOCKER_IMAGE_TAG := $(BUILD_VERSION)-$(GIT_COMMIT_DATE)-$(GIT_COMMIT_SHORT)
DOCKER_LABEL_VENDOR := SnapServ
DOCKER_LABEL_URL := https://snapserv.net
DOCKER_LABEL_VCS_URL := https://github.com/snapserv/docker
DOCKER_BUILD_FLAGS ?=

GOSS_FILES_PATH := ../
GOSS_FILES_STRATEGY := mount
GOSS_OPTS := --color --retry-timeout 30s --sleep 1s

# Check if working directory is dirty
GIT_CLEAN_REPO_CHECK := $(strip $(shell git status --porcelain))
GIT_CLEAN_REPO_CHECK := $(if $(firstword $(GIT_CLEAN_REPO_CHECK)),no,yes)
ifneq ($(GIT_CLEAN_REPO_CHECK),yes)
DOCKER_IMAGE_TAG := $(DOCKER_IMAGE_TAG)-dirty
endif

# Mark as release if current commit matches build tag commit (skip in debug)
GIT_TAG_COMMIT := $(strip $(shell git rev-list "$(BUILD_TAG)" --max-count=1 2>&-))
ifeq ($(DEBUG),)
ifeq ($(GIT_COMMIT),$(GIT_TAG_COMMIT))
$(info release build: current commit [$(GIT_COMMIT)] matches tag commit [$(GIT_TAG_COMMIT)])
RELEASE_GOAL_CHECK := yes
else
$(info test build: current commit [$(GIT_COMMIT)] does not match tag commit [$(GIT_TAG_COMMIT)])
RELEASE_GOAL_CHECK := no
endif
else
$(info test build: forced for commit [$(GIT_COMMIT)] due to DEBUG variable being set)
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
$(info ============================== $(DOCKER_IMAGE_NAME) ==============================)
$(info >> Build Identifier: $(BUILD_VERSION) @ $(BUILD_DATE))
$(info >> Git Commit: $(GIT_COMMIT) @ $(GIT_COMMIT_DATE))
$(info >> Docker Image: $(DOCKER_IMAGE_PATH):$(DOCKER_IMAGE_TAG))
$(info >> Flags: cleanRepo=$(GIT_CLEAN_REPO_CHECK) releaseGoal=$(RELEASE_GOAL_CHECK))
$(info )

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

	# Run dgoss for testing docker images without goss
	dgoss run -it --rm \
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

.PHONY: default release test build lint login push output auto
