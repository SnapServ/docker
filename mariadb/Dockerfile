FROM quay.io/snapserv/base-alpine:1.1.15@sha256:34f27840f7c7aa20a7b78ea2a9167daa8a690b19c71e40547b68216ba5266318

RUN true \
    # Install MariaDB
    && apk add --no-cache \
    mariadb \
    mariadb-client \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 mariadb \
    && ctutil directory -u mariadb -g mariadb -m 0700 \
        /cts/mariadb/persistent/data \
        /cts/mariadb/volatile/run \
        /cts/mariadb/volatile/tmp \
    && true

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

USER 2000
EXPOSE 3306/tcp
VOLUME [ "/cts/mariadb/persistent", "/cts/mariadb/volatile" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
