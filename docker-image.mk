# Ensure image name has been passed to Makefile
ifndef DOCKER_IMAGE_NAME
$(error missing required variable: DOCKER_IMAGE_NAME)
endif

# Declare build variables
DOCKER_LABEL_VENDOR := SnapServ
DOCKER_LABEL_URL := https://snapserv.net
DOCKER_LABEL_VCS_URL := https://github.com/snapserv/docker

DOCKER_REGISTRY := https://quay.io
DOCKER_IMAGE_PATH := quay.io/snapserv/$(DOCKER_IMAGE_NAME)
DOCKER_BUILD_TAG := latest
DOCKER_BUILD_FLAGS ?=

# Combined targets
default: build output
release: test push output
test: lint build

# Build container image
build:
	docker build $(DOCKER_BUILD_FLAGS) \
		--label org.label-schema.name="$(DOCKER_IMAGE_NAME)" \
		--label org.label-schema.vendor="$(DOCKER_LABEL_VENDOR)" \
		--label org.label-schema.url="$(DOCKER_LABEL_URL)" \
		--label org.label-schema.vcs-url="$(DOCKER_LABEL_VCS_URL)" \
		--label org.label-schema.schema-version="1.0" \
		--tag $(DOCKER_IMAGE_PATH):$(DOCKER_BUILD_TAG) .

# Lint dockerfile
lint:
	cat Dockerfile | docker run \
		-i --rm hadolint/hadolint hadolint - \
		--ignore DL3007 --ignore DL3018 --ignore SC1091

# Login to registry
login:
	@echo "$(DOCKER_REGISTRY_PASSWORD)" | docker login \
		-u "$(DOCKER_REGISTRY_USERNAME)" --password-stdin "$(DOCKER_REGISTRY)"

# Push image to registry
push: login
	docker push $(DOCKER_IMAGE_PATH):$(DOCKER_BUILD_TAG)

# Output image name
output:
	@echo Docker Image: $(DOCKER_IMAGE_PATH):$(DOCKER_BUILD_TAG)

.PHONY: default release test build lint login push output
