FROM quay.io/snapserv/base-alpine:1.1.15@sha256:34f27840f7c7aa20a7b78ea2a9167daa8a690b19c71e40547b68216ba5266318

ENV PROSODY_VERSION="0.11.3"
ENV PROSODY_MODULES_VERSION="362997ededb1"

RUN true \
    # Install runtime dependencies
    && apk add --no-cache \
        prosody~="${PROSODY_VERSION}" \
        lua5.2-dbi-mysql \
    # Install build dependencies
    && apk add --no-cache --virtual .build-deps \
        mercurial \
    # Download community modules
    && hg clone -r "${PROSODY_MODULES_VERSION}" https://hg.prosody.im/prosody-modules /usr/local/lib/prosody-modules \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 prosody \
    && ctutil directory -u prosody -g prosody -m 0700 \
        /cts/prosody/configs \
        /cts/prosody/secrets \
        /cts/prosody/persistent \
        /cts/prosody/volatile/run \
    && ln -sf /cts/prosody/persistent/prosody.cfg.lua /etc/prosody/prosody.cfg.lua \
    # Uninstall build dependencies
    && apk del --purge --no-cache .build-deps \
    && true

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

USER 2000
EXPOSE 5000/tcp 5222/tcp 5269/tcp 5280/tcp
VOLUME [ "/cts/prosody/persistent", "/cts/prosody/volatile/run" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
