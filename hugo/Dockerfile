FROM quay.io/snapserv/base-alpine:1.1.13@sha256:e989f2d5b639f249a23c83d781f55761145d94b05afdae946eb38250f7f06073

RUN true \
    # Install Hugo
    && apk add --no-cache hugo \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 hugo \
    && ctutil directory -u hugo -g hugo -m 0700 \
        /cts/hugo/persistent/data \
    && true

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

USER 2000
EXPOSE 1313/tcp
VOLUME [ "/cts/hugo/persistent" ]

WORKDIR /cts/hugo/persistent/data
ENTRYPOINT [ "/docker-entrypoint.sh" ]
