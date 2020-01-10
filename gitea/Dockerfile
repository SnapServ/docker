FROM gitea/gitea:1.10.2@sha256:6840e92bfa48a789294017205e56aa23aa4ad2dafaa3c0cfad32f26e4ea73794 AS gitea
FROM quay.io/snapserv/base-alpine:1.1.3@sha256:5d12b847e8c3ffda75d72bf3d0e450330d194033e5794bd77f00c4e1823068e1

RUN true \
    # Install runtime dependencies
    && apk add --no-cache git \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 -h /cts/gitea/persistent/home gitea \
    && ctutil directory -u gitea -g gitea -m 0700 \
        /cts/gitea/persistent/data \
        /cts/gitea/persistent/home \
    && true

COPY --from=gitea /app/gitea/gitea /usr/local/bin/gitea

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

USER gitea
EXPOSE 2222/tcp 3000/tcp
VOLUME [ "/cts/gitea/persistent" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
