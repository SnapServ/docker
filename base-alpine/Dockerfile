FROM alpine:3.10.3@sha256:e4355b66995c96b4b468159fc5c7e3540fcef961189ca13fee877798649f531a
SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]

RUN true \
    # Install required packages
    && apk add --no-cache --virtual .base \
    ca-certificates \
    gomplate \
    libcap \
    multirun \
    openssl \
    su-exec \
    && true

COPY rootfs /
RUN chmod 0755 /usr/bin/scp
