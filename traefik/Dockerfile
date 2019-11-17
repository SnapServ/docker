FROM quay.io/snapserv/base-alpine:1.0.4@sha256:9b87e662728d9b111341504349607e6b266f359361ba435d669b1672dcd1b896

ENV TRAEFIK_VERSION=v2.1.0-rc2

RUN true \
    # Install build-time dependencies
    && apk add --no-cache --virtual .build \
    curl \
    # Install Traefik
    && curl -fsSL "https://github.com/containous/traefik/releases/download/${TRAEFIK_VERSION}/traefik_${TRAEFIK_VERSION}_linux_amd64.tar.gz" -o /tmp/traefik.tar.gz \
    && tar -xf /tmp/traefik.tar.gz -C /usr/local/bin traefik \
    && chmod 0755 /usr/local/bin/traefik \
    && rm -f /tmp/traefik.tar.gz \
    # Add system account and group
    && addgroup -S traefik \
    && adduser -S -s /bin/false -G traefik traefik \
    # Prepare directories
    && mkdir -p /cts/traefik/config /cts/traefik/data \
    && chown traefik:traefik /cts/traefik/* \
    && chmod 0700 /cts/traefik/* \
    # Remove build-time dependencies
    && apk del .build \
    && true

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

EXPOSE 8080/tcp 8081/tcp 8443/tcp
ENTRYPOINT [ "/docker-entrypoint.sh" ]
VOLUME [ "/cts/traefik/config", "/cts/traefik/data" ]
