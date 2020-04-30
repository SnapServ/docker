FROM quay.io/snapserv/base-alpine:1.1.13@sha256:e989f2d5b639f249a23c83d781f55761145d94b05afdae946eb38250f7f06073

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
