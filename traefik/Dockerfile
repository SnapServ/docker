FROM traefik:v2.1.1@sha256:b1fe8eec6330ffe542f313a21860361f266375f854804ed19893933f65a62e67 AS traefik
FROM quay.io/snapserv/base-alpine:1.1.3@sha256:5d12b847e8c3ffda75d72bf3d0e450330d194033e5794bd77f00c4e1823068e1

RUN true \
    && ctutil account -u 2000 -g 2000 traefik \
    && ctutil directory -u traefik -g traefik -m 0700 /cts/traefik/persistent \
    && true

COPY --from=traefik /usr/local/bin/traefik /usr/local/bin/traefik
COPY rootfs /

USER traefik
EXPOSE 8081/tcp
VOLUME [ "/cts/traefik/persistent" ]

ENTRYPOINT [ "/usr/local/bin/traefik" ]
CMD [ "--api.insecure=true", "--ping=true", "--entrypoints.traefik.address=:8081" ]
