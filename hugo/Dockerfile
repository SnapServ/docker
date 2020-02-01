FROM quay.io/snapserv/base-alpine:1.1.10@sha256:79e4a4502ad2e287a2b5fdad68fd18b97b3a55ee5c09be197adc0263cd61b9a1

RUN true \
    # Install Hugo
    && apk add --no-cache hugo \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 hugo \
    && ctutil directory -u hugo -g hugo -m 0700 \
        /cts/hugo/persistent/data \
        /cts/hugo/volatile/tmp \
    && true

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

USER hugo
EXPOSE 1313/tcp
VOLUME [ "/cts/hugo/persistent", "/cts/hugo/volatile" ]

WORKDIR /cts/hugo/persistent/data
ENTRYPOINT [ "/docker-entrypoint.sh" ]
