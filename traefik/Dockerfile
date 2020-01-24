FROM traefik:2.1.3@sha256:fa0da7a651b89493593892f0b434abbfad6eae079c406311d22c2b8878a477f8 AS traefik
FROM quay.io/snapserv/base-alpine:1.1.9@sha256:5245bf05606d652078946f4fd234154059903b6705eee741c01ef005a4c5c5d6

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
