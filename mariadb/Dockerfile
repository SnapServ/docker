FROM quay.io/snapserv/base-alpine:1.1.2@sha256:a90e71856f4cc2839fdbbbb4fba7572dcf184432d3a480ee64df8c80440d8c30

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

USER mariadb
EXPOSE 3306/tcp
VOLUME [ "/cts/mariadb/persistent", "/cts/mariadb/volatile" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
