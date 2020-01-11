FROM quay.io/snapserv/base-alpine:1.1.3@sha256:5d12b847e8c3ffda75d72bf3d0e450330d194033e5794bd77f00c4e1823068e1

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
