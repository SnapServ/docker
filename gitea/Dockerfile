FROM gitea/gitea:1.10.1 AS gitea
FROM quay.io/snapserv/base-alpine:1.0.7

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
