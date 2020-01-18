FROM gitea/gitea:1.10.3@sha256:5a86cf46edbe69a8589c3aabb4cae8adee09236977e9a5f83d36fa83c06013eb AS gitea
FROM quay.io/snapserv/base-alpine:1.1.7@sha256:63173770ee3f0a4cebcb12225198eecae7dcb3103c3e633ab18e5ec7985114f7

RUN true \
    # Install runtime dependencies
    && apk add --no-cache git \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 -h /cts/gitea/persistent/home gitea \
    && ctutil directory -u gitea -g gitea -m 0700 \
        /cts/gitea/persistent/data \
        /cts/gitea/persistent/home \
    && true

COPY --from=gitea /app/gitea/gitea /usr/local/bin/gitea

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

USER 2000
EXPOSE 2222/tcp 3000/tcp
VOLUME [ "/cts/gitea/persistent" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
