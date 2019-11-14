IMAGE_TARGETS := $(sort $(dir $(wildcard */Dockerfile)))
IMAGE_GOALS := $(strip $(shell sed -En 's/.PHONY: (.*)/\1/p' docker-image.mk | tail -n1))

ACTIVE_TARGETS := $(filter $(MAKECMDGOALS),$(IMAGE_TARGETS))
ACTIVE_TARGETS := $(if $(ACTIVE_TARGETS),$(ACTIVE_TARGETS),$(IMAGE_TARGETS))
ACTIVE_GOALS := $(filter-out $(IMAGE_TARGETS),$(MAKECMDGOALS))

$(IMAGE_GOALS): $(ACTIVE_TARGETS)

$(IMAGE_TARGETS):
	$(eval DOCKER_IMAGE_NAME := $(shell echo $(@:/=)))
	$(eval export DOCKER_IMAGE_NAME)

	$(MAKE) -f ../docker-image.mk -C $@ $(ACTIVE_GOALS)

.PHONY: $(IMAGE_GOALS) $(IMAGE_TARGETS)

nginx-php-fpm/: base-alpine/
