FROM joohoi/acme-dns:v0.8@sha256:70e7035969c7c9f2208b6ecc3097d9f199e9d7e8d2e112e9d32bc33533c70b1d AS acme-dns
FROM quay.io/snapserv/base-alpine:1.1.15@sha256:34f27840f7c7aa20a7b78ea2a9167daa8a690b19c71e40547b68216ba5266318

RUN true \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 acme-dns \
    && ctutil directory -u acme-dns -g acme-dns -m 0700 /cts/acme-dns/persistent \
    && true

COPY --from=acme-dns /root/acme-dns /usr/local/bin/acme-dns
COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

USER 2000
EXPOSE 5353/tcp 5353/udp 8080/tcp
VOLUME [ "/cts/acme-dns/persistent" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
