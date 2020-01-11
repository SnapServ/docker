FROM quay.io/snapserv/base-alpine:1.1.3@sha256:5d12b847e8c3ffda75d72bf3d0e450330d194033e5794bd77f00c4e1823068e1

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
