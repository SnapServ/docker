FROM quay.io/snapserv/base-alpine:1.1.15@sha256:34f27840f7c7aa20a7b78ea2a9167daa8a690b19c71e40547b68216ba5266318

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
