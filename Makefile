# Build list of possible targets and goals by scanning the directory
IMAGE_TARGETS := $(sort $(dir $(wildcard */Dockerfile)))
IMAGE_TARGETS_NTS := $(IMAGE_TARGETS:%/=%)
IMAGE_GOALS := $(strip $(shell sed -En 's/.PHONY: (.*)/\1/p' docker-image.mk | tail -n1))
IMAGE_GOALS := $(addprefix @,$(filter-out auto,$(IMAGE_GOALS)))

# Extract active targets and goals from make goals
ACTIVE_GOALS := $(filter @%,$(MAKECMDGOALS))
ACTIVE_TARGETS := $(filter-out $(ACTIVE_GOALS),$(MAKECMDGOALS))
ACTIVE_TARGETS := $(if $(ACTIVE_TARGETS),$(ACTIVE_TARGETS),$(IMAGE_TARGETS))
ACTIVE_GOALS := $(ACTIVE_GOALS:@%=%)

# Debug information about active goals and targets
$(info Supported Goals: $(IMAGE_GOALS))
$(info Supported Targets: $(IMAGE_TARGETS))
$(info Active Goals: $(ACTIVE_GOALS))
$(info Active Targets: $(ACTIVE_TARGETS))

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

# If no changed images were found, build all of them
ifeq ($(CHANGED_IMAGES),)
CHANGED_IMAGES_FALLBACK := $(IMAGE_TARGETS)
endif

# Build all images unconditionally
all: $(IMAGE_TARGETS)

# Auto-detect changes and only build when necessary
auto: $(CHANGED_IMAGES) $(CHANGED_IMAGES_FALLBACK)
	$(info Changed Images: $(CHANGED_IMAGES))

# Execute goal on all active targets
$(IMAGE_GOALS): $(ACTIVE_TARGETS)

# Support explicitely listing single/multiple targets
$(IMAGE_TARGETS):
	$(eval DOCKER_IMAGE_NAME := $(shell echo $(@:/=)))
	$(eval export DOCKER_IMAGE_NAME)

	$(MAKE) -f ../docker-image.mk -C $@ $(ACTIVE_GOALS)

# Support image targets without trailing slash
$(IMAGE_TARGETS_NTS): $(addsuffix /,$(filter-out %/,$(ACTIVE_TARGETS)))

.PHONY: all auto $(IMAGE_GOALS) $(IMAGE_TARGETS) $(IMAGE_TARGETS_NTS)
