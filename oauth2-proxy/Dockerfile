FROM quay.io/pusher/oauth2_proxy:v4.1.0-amd64@sha256:dbe773744a8a617a4f2bd9376c7ce1c9f48de28b39a652dd01957848210be807 AS oauth2-proxy
FROM quay.io/snapserv/base-alpine:1.1.10@sha256:79e4a4502ad2e287a2b5fdad68fd18b97b3a55ee5c09be197adc0263cd61b9a1

RUN true \
    && ctutil account -u 2000 -g 2000 oauth2-proxy \
    && true

COPY --from=oauth2-proxy /bin/oauth2_proxy /usr/local/bin/oauth2-proxy
COPY rootfs /

USER oauth2-proxy
EXPOSE 4180/tcp

ENTRYPOINT [ "/usr/local/bin/oauth2-proxy" ]
CMD [ "-http-address=[::]:4180", "-ping-path=/ping", "-silence-ping-logging" ]
