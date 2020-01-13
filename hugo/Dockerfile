FROM quay.io/snapserv/base-alpine:1.1.5@sha256:bdb842e45ba409ff048f6c23fd954c38ca2c755014a559aba10f744e7484faea

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
