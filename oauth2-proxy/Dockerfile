FROM quay.io/pusher/oauth2_proxy:v5.1.1-amd64@sha256:9adeb10f59346d93bb02fb8dd628dbbb7def9a0529667579829903ce2b52f496 AS oauth2-proxy
FROM quay.io/snapserv/base-alpine:1.1.15@sha256:34f27840f7c7aa20a7b78ea2a9167daa8a690b19c71e40547b68216ba5266318

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
