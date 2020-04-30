FROM quay.io/pusher/oauth2_proxy:v5.1.0-amd64@sha256:1fad3f247a8edeceead03230d833fcb4c3935a3a57b83787690f15f7daa6b59b AS oauth2-proxy
FROM quay.io/snapserv/base-alpine:1.1.13@sha256:e989f2d5b639f249a23c83d781f55761145d94b05afdae946eb38250f7f06073

RUN true \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 oauth2-proxy \
    && true

COPY --from=oauth2-proxy /bin/oauth2_proxy /usr/local/bin/oauth2-proxy
COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

USER 2000
EXPOSE 4180/tcp

ENTRYPOINT [ "/docker-entrypoint.sh" ]
