FROM alpine:3.10.3@sha256:e4355b66995c96b4b468159fc5c7e3540fcef961189ca13fee877798649f531a
SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]

ENV GOSS_VERSION=v0.3.7

RUN true \
    # Install runtime dependencies
    && apk add --no-cache --virtual .base \
    ca-certificates \
    libcap \
    su-exec \
    # Install build-time dependencies
    && apk add --no-cache --virtual .build \
    curl \
    # Install Goss
    && curl -fsSL "https://github.com/aelsabbahy/goss/releases/download/${GOSS_VERSION}/goss-linux-amd64" -o /usr/local/bin/goss \
    && chmod 0755 /usr/local/bin/goss \
    # Remove build-time dependencies
    && apk del .build \
    && true

COPY rootfs /
RUN true \
    # Ensure correct file permissions for copied files
    && chmod 0755 /usr/local/bin/scp \
    && chmod 0644 /usr/local/lib/scp \
    && true
