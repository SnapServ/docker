FROM gitea/gitea:1.10.1@sha256:d8460c5ee7e6dbfbf2c9d9231f9f43f1b55b6b457e66d5df5cec00813e47ef13 AS gitea
FROM quay.io/snapserv/base-alpine:1.0.7@sha256:c70085949b4792b67d79ee4408002ac90d644b7f59a38208b1e3b02aa129e45d

ENV GITEA_UID=1000 \
    GITEA_GID=1000

RUN true \
    # Install runtime dependencies
    && apk add --no-cache \
    git \
    # Add service account
    && mkdir -p /cts/gitea/data \
    && addgroup -S -g "${GITEA_GID}" gitea \
    && adduser -S -s /bin/false -h /cts/gitea/data -G gitea -u "${GITEA_UID}" gitea \
    && true

COPY --from=gitea /app/gitea/gitea /usr/local/bin/gitea

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

EXPOSE 2222/tcp 3000/tcp
ENTRYPOINT [ "/docker-entrypoint.sh" ]
VOLUME [ "/cts/gitea/data" ]
