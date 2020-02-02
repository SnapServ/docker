FROM quay.io/snapserv/base-alpine:1.1.11@sha256:687154bc9982b227224c33a95b2d8bd20204791ca929bcb939eabf4c5ee46a4c

RUN true \
    # Install Postgres
    && apk add --no-cache \
      postgresql \
      postgresql-client \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 postgres \
    && ctutil directory -u postgres -g postgres -m 0700 \
      /cts/postgres/persistent \
      /cts/postgres/volatile \
    && true

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

ENV PGDATA="/cts/postgres/persistent/data" \
    PGHOST="/cts/postgres/volatile"

USER 2000
EXPOSE 5432/tcp
VOLUME [ "/cts/postgres/persistent", "/cts/postgres/volatile" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
