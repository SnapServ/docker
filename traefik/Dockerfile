FROM traefik:v2.1.1@sha256:b1fe8eec6330ffe542f313a21860361f266375f854804ed19893933f65a62e67 AS traefik
FROM quay.io/snapserv/base-alpine:1.1.0@sha256:fa5c177e40e14e84fcdb92c3f94fa1bc41177e83d01fd4eb5c5f120ded13f0cb

RUN true \
    && ctutil account -u 2000 -g 2000 traefik \
    && ctutil directory -u traefik -g traefik -m 0700 /cts/traefik \
    && true

COPY --from=traefik /usr/local/bin/traefik /usr/local/bin/traefik
COPY rootfs /

USER traefik
EXPOSE 8081/tcp
VOLUME [ "/cts/traefik" ]

ENTRYPOINT [ "/usr/local/bin/traefik" ]
CMD [ "--api.insecure=true", "--ping=true", "--entrypoints.traefik.address=:8081" ]
