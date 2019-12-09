FROM quay.io/snapserv/base-alpine:1.0.7@sha256:c70085949b4792b67d79ee4408002ac90d644b7f59a38208b1e3b02aa129e45d

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
