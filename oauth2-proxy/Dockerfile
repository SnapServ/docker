FROM quay.io/pusher/oauth2_proxy:v4.1.0-amd64@sha256:dbe773744a8a617a4f2bd9376c7ce1c9f48de28b39a652dd01957848210be807 AS oauth2-proxy
FROM quay.io/snapserv/base-alpine:1.0.9@sha256:e80dfe9b9999d72ddf8aed7b3a460dc1ed97485f8bfd6c5bcc3871f07a26af99

RUN true \
    # Add service account
    && addgroup -S -g 1000 oauth2-proxy \
    && adduser -S -s /bin/false -G oauth2-proxy -u 1000 oauth2-proxy \
    && true

COPY --from=oauth2-proxy /bin/oauth2_proxy /usr/local/bin/oauth2-proxy

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

EXPOSE 4180/tcp
ENTRYPOINT [ "/docker-entrypoint.sh" ]
