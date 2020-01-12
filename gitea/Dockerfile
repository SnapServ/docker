FROM gitea/gitea:1.10.2@sha256:6840e92bfa48a789294017205e56aa23aa4ad2dafaa3c0cfad32f26e4ea73794 AS gitea
FROM quay.io/snapserv/base-alpine:1.1.4@sha256:f778e085ca5a9cdeba83b074161fb3ab6350a8d4112bb8ecc9d682a8bf600790

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
