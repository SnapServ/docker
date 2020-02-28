FROM quay.io/pusher/oauth2_proxy:v5.0.0-amd64@sha256:dab7f9d644fdf9a533d6357f5bce3c704b52580a135afac88f961043bc9559bc AS oauth2-proxy
FROM quay.io/snapserv/base-alpine:1.1.12@sha256:0da90bf7840e695fff845e27f3bd2cd9a5115e99ebc0be7d87337b631967cb3e

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
