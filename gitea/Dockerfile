FROM gitea/gitea:1.11.4@sha256:5aed363a31a1cadec119faec97993efe5eca1a7e6efa71380fc9d7a2c519b2c5 AS gitea
FROM quay.io/snapserv/base-alpine:1.1.15@sha256:34f27840f7c7aa20a7b78ea2a9167daa8a690b19c71e40547b68216ba5266318

RUN true \
    # Install runtime dependencies
    && apk add --no-cache \
    git \
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
