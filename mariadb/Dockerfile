FROM quay.io/snapserv/base-alpine:1.0.7

ENV MARIADB_UID=1000 \
    MARIADB_GID=1000

RUN true \
    # Install required packages
    && apk add --no-cache \
    git \
    mariadb \
    mariadb-client \
    tzdata \
    # Add service account
    && addgroup -S -g "${MARIADB_GID}" mariadb \
    && adduser -S -s /bin/false -G mariadb -u "${MARIADB_UID}" mariadb \
    && true

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

EXPOSE 3306/tcp
ENTRYPOINT [ "/docker-entrypoint.sh" ]
VOLUME [ "/cts/mariadb/data" ]
