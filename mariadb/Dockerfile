FROM quay.io/snapserv/base-alpine:1.1.5@sha256:bdb842e45ba409ff048f6c23fd954c38ca2c755014a559aba10f744e7484faea

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
