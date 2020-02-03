FROM quay.io/snapserv/base-alpine:1.1.11@sha256:687154bc9982b227224c33a95b2d8bd20204791ca929bcb939eabf4c5ee46a4c

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
