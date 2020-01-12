FROM quay.io/snapserv/base-alpine:1.1.4@sha256:f778e085ca5a9cdeba83b074161fb3ab6350a8d4112bb8ecc9d682a8bf600790

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
