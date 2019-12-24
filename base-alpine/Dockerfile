FROM alpine:3.11.2@sha256:3983cc12fb9dc20a009340149e382a18de6a8261b0ac0e8f5fcdf11f8dd5937e
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
