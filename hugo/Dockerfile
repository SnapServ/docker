FROM quay.io/snapserv/base-alpine:1.1.9@sha256:5245bf05606d652078946f4fd234154059903b6705eee741c01ef005a4c5c5d6

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
