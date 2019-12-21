FROM traefik:v2.1.1@sha256:a87b61f3254d03c4fcc0b994e2cb7af89abba8178f1fbec3bce3f4bdc080f8a6 AS traefik
FROM quay.io/snapserv/base-alpine:1.0.9@sha256:e80dfe9b9999d72ddf8aed7b3a460dc1ed97485f8bfd6c5bcc3871f07a26af99

RUN true \
    # Add service account
    && addgroup -S traefik \
    && adduser -S -s /bin/false -G traefik traefik \
    # Prepare persistent directories
    && mkdir -p /cts/traefik/config /cts/traefik/data \
    && chown traefik:traefik /cts/traefik/config /cts/traefik/data \
    && chmod 0700 /cts/traefik/config /cts/traefik/data \
    && true

COPY --from=traefik /usr/local/bin/traefik /usr/local/bin/traefik

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

EXPOSE 8080/tcp 8081/tcp 8443/tcp
ENTRYPOINT [ "/docker-entrypoint.sh" ]
VOLUME [ "/cts/traefik/config", "/cts/traefik/data" ]
