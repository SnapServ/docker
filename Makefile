# Build list of possible targets and goals by scanning the directory
IMAGE_TARGETS := $(sort $(dir $(wildcard */Dockerfile)))
IMAGE_GOALS := $(strip $(shell sed -En 's/.PHONY: (.*)/\1/p' docker-image.mk | tail -n1))
IMAGE_GOALS := $(filter-out $(IMAGE_GOALS),auto)

# Extract active targets and goals from make goals
ACTIVE_TARGETS := $(filter $(MAKECMDGOALS),$(IMAGE_TARGETS))
ACTIVE_TARGETS := $(if $(ACTIVE_TARGETS),$(ACTIVE_TARGETS),$(IMAGE_TARGETS))
ACTIVE_GOALS := $(filter-out $(IMAGE_TARGETS),$(MAKECMDGOALS))

# Check if commit range to detect changes for automatic builds
ifdef COMMIT_RANGE
## Replace ... with .. in commit range, then search for all commits
COMMIT_RANGE := $(subst ...,..,$(COMMIT_RANGE))
COMMITTED_TARGETS := $(strip $(shell git diff --name-only $(COMMIT_RANGE) **/ | awk -F/ '{print $$(1)"/"}'))
else
## Use cached/staged changes instead
COMMITTED_TARGETS := $(strip $(shell git diff --name-only --cached HEAD **/ | awk -F/ '{print $$(1)"/"}'))
endif

# Extract specific tag for current commit (if present) and build list of changed images
TAGGED_TARGETS := $(strip $(shell git describe --abbrev=0 --tags --exact-match 2>&- | awk -F/ '{print $$(1)"/"}'))
CHANGED_IMAGES := $(sort $(TAGGED_TARGETS) $(COMMITTED_TARGETS))

# Execute goal on all active targets
$(IMAGE_GOALS): $(ACTIVE_TARGETS)

# Support explicitely listing single/multiple targets
$(IMAGE_TARGETS):
	$(eval DOCKER_IMAGE_NAME := $(shell echo $(@:/=)))
	$(eval export DOCKER_IMAGE_NAME)

	$(MAKE) -f ../docker-image.mk -C $@ $(ACTIVE_GOALS)

# Auto-detect changes and only build when necessary
auto: $(CHANGED_IMAGES)
	$(info Changed Images: $(CHANGED_IMAGES))

.PHONY: $(IMAGE_GOALS) $(IMAGE_TARGETS) auto

# Image target dependencies
nginx-php-fpm/: base-alpine/
