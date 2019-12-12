FROM quay.io/snapserv/base-alpine:1.0.9@sha256:e80dfe9b9999d72ddf8aed7b3a460dc1ed97485f8bfd6c5bcc3871f07a26af99

ENV MARIADB_UID=1000 \
    MARIADB_GID=1000

RUN true \
    # Install required packages
    && apk add --no-cache \
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
