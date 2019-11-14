FROM alpine:3.10.3
SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]

RUN true \
    && apk add --no-cache --virtual .base \
    ca-certificates \
    gomplate \
    libcap \
    multirun \
    su-exec \
    && true

COPY rootfs /

RUN true \
    && chmod 0755 /usr/bin/scp-* \
    && true
