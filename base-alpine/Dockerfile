FROM alpine:3.11.0@sha256:d371657a4f661a854ff050898003f4cb6c7f36d968a943c1d5cde0952bd93c80
SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]

RUN true \
    # Install runtime dependencies
    && apk add --no-cache --virtual .base \
    ca-certificates \
    gomplate \
    libcap \
    su-exec \
    tzdata \
    && true

COPY rootfs /
RUN true \
    # Ensure correct file permissions for copied files
    && chmod 0755 /usr/local/bin/scp \
    && chmod 0644 /usr/local/lib/scp \
    && true
