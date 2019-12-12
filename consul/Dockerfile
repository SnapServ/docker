FROM quay.io/snapserv/base-alpine:1.0.9@sha256:e80dfe9b9999d72ddf8aed7b3a460dc1ed97485f8bfd6c5bcc3871f07a26af99

ENV CONSUL_VERSION=1.6.2

RUN true \
    # Install build-time dependencies
    && apk add --no-cache --virtual .build \
    curl \
    # Install Consul
    && curl -fsSL "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" -o /tmp/consul.zip \
    && unzip -d /usr/local/bin /tmp/consul.zip \
    && chmod 0755 /usr/local/bin/consul \
    && rm -f /tmp/consul.zip \
    # Add system account and group
    && addgroup -S consul \
    && adduser -S -s /bin/false -G consul consul \
    # Prepare directories
    && mkdir -p /cts/consul/config /cts/consul/data \
    && chown consul:consul /cts/consul/* \
    && chmod 0700 /cts/consul/* \
    # Remove build-time dependencies
    && apk del .build \
    && true

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

EXPOSE 8300/tcp 8301/tcp 8301/udp 8302/tcp 8302/udp 8500/tcp 8600/tcp 8600/udp

ENTRYPOINT [ "/docker-entrypoint.sh" ]
VOLUME [ "/cts/consul/config", "/cts/consul/data" ]
