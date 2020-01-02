FROM gitea/gitea:1.10.2@sha256:6840e92bfa48a789294017205e56aa23aa4ad2dafaa3c0cfad32f26e4ea73794 AS gitea
FROM quay.io/snapserv/base-alpine:1.0.9@sha256:e80dfe9b9999d72ddf8aed7b3a460dc1ed97485f8bfd6c5bcc3871f07a26af99

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
