FROM quay.io/snapserv/base-alpine:1.1.13@sha256:e989f2d5b639f249a23c83d781f55761145d94b05afdae946eb38250f7f06073

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
