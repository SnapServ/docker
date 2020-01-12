FROM traefik:v2.1.2@sha256:b45214fe976f562a2960b31d651937ff0b38096a5e190aa054ccd0d731c6999f AS traefik
FROM quay.io/snapserv/base-alpine:1.1.4@sha256:f778e085ca5a9cdeba83b074161fb3ab6350a8d4112bb8ecc9d682a8bf600790

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
