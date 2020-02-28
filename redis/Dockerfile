FROM quay.io/snapserv/base-alpine:1.1.12@sha256:0da90bf7840e695fff845e27f3bd2cd9a5115e99ebc0be7d87337b631967cb3e

RUN true \
    # Install Redis
    && apk add --no-cache \
        redis \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 redis \
    && ctutil directory -u redis -g redis -m 0700 \
        /cts/redis/persistent \
    && true

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

USER 2000
EXPOSE 5432/tcp
VOLUME [ "/cts/redis/persistent" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
