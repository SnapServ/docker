IMAGE_TARGETS := $(sort $(dir $(wildcard */Dockerfile)))
IMAGE_GOALS := $(strip $(shell sed -En 's/.PHONY: (.*)/\1/p' docker-image.mk | tail -n1))
IMAGE_GOALS := $(filter-out $(IMAGE_GOALS),auto)

ACTIVE_TARGETS := $(filter $(MAKECMDGOALS),$(IMAGE_TARGETS))
ACTIVE_TARGETS := $(if $(ACTIVE_TARGETS),$(ACTIVE_TARGETS),$(IMAGE_TARGETS))
ACTIVE_GOALS := $(filter-out $(IMAGE_TARGETS),$(MAKECMDGOALS))

TAGGED_TARGETS := $(strip $(shell git describe --abbrev=0 --tags --exact-match 2>&- | awk -F/ '{print $$(1)"/"}'))
COMMITTED_TARGETS := $(strip $(shell git diff --name-only HEAD~1..HEAD **/ | awk -F/ '{print $$(1)"/"}'))
CHANGED_IMAGES := $(sort $(TAGGED_TARGETS) $(COMMITTED_TARGETS))

$(IMAGE_GOALS): $(ACTIVE_TARGETS)

$(IMAGE_TARGETS):
	$(eval DOCKER_IMAGE_NAME := $(shell echo $(@:/=)))
	$(eval export DOCKER_IMAGE_NAME)

	$(MAKE) -f ../docker-image.mk -C $@ $(ACTIVE_GOALS)

auto: $(CHANGED_IMAGES)

.PHONY: $(IMAGE_GOALS) $(IMAGE_TARGETS) auto

nginx-php-fpm/: base-alpine/
