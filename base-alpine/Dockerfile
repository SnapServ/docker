FROM alpine:3.10.3
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
