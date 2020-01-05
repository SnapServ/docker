FROM quay.io/pusher/oauth2_proxy:v4.1.0-amd64@sha256:dbe773744a8a617a4f2bd9376c7ce1c9f48de28b39a652dd01957848210be807 AS oauth2-proxy
FROM quay.io/snapserv/base-alpine:1.1.0@sha256:fa5c177e40e14e84fcdb92c3f94fa1bc41177e83d01fd4eb5c5f120ded13f0cb

RUN true \
    && ctutil account -u 2000 -g 2000 oauth2-proxy \
    && true

COPY --from=oauth2-proxy /bin/oauth2_proxy /usr/local/bin/oauth2-proxy
COPY rootfs /

USER oauth2-proxy
EXPOSE 4180/tcp

ENTRYPOINT [ "/usr/local/bin/oauth2-proxy" ]
CMD [ "-http-address=[::]:4180", "-ping-path=/ping", "-silence-ping-logging" ]
