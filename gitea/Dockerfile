FROM gitea/gitea:1.11.1@sha256:b038973ab4ee1a04ac5518124c7b5be32aa46cb0fa025adb2b11af38b1acc6a3 AS gitea
FROM quay.io/snapserv/base-alpine:1.1.12@sha256:0da90bf7840e695fff845e27f3bd2cd9a5115e99ebc0be7d87337b631967cb3e

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
