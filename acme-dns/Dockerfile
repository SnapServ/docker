FROM joohoi/acme-dns:v0.8@sha256:70e7035969c7c9f2208b6ecc3097d9f199e9d7e8d2e112e9d32bc33533c70b1d AS acme-dns
FROM quay.io/snapserv/base-alpine:1.1.4@sha256:f778e085ca5a9cdeba83b074161fb3ab6350a8d4112bb8ecc9d682a8bf600790

RUN true \
    && ctutil account -u 2000 -g 2000 acme-dns \
    && ctutil directory -u acme-dns -g acme-dns -m 0700 /cts/acme-dns/volatile \
    && true

COPY --from=acme-dns /root/acme-dns /usr/local/bin/acme-dns
COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

USER acme-dns
EXPOSE 5353/tcp 5353/udp 8080/tcp
VOLUME [ "/cts/acme-dns/volatile" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
