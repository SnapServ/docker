FROM quay.io/snapserv/base-alpine:1.1.10@sha256:79e4a4502ad2e287a2b5fdad68fd18b97b3a55ee5c09be197adc0263cd61b9a1

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
