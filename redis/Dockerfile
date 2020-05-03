FROM quay.io/snapserv/base-alpine:1.1.15@sha256:34f27840f7c7aa20a7b78ea2a9167daa8a690b19c71e40547b68216ba5266318

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
