FROM quay.io/snapserv/base-alpine:1.1.9@sha256:5245bf05606d652078946f4fd234154059903b6705eee741c01ef005a4c5c5d6

RUN true \
    # Install runtime dependencies
    && apk add --no-cache \
      libffi \
      libjpeg-turbo \
      libressl \
      postgresql-libs \
      py3-virtualenv \
      python3 \
      zlib \
    && true

WORKDIR /opt/synapse
COPY rootfs/opt/synapse/requirements.txt /opt/synapse/

RUN true \
    # Install build dependencies
    && apk add --no-cache --virtual .build-deps \
      gcc \
      libffi-dev \
      libjpeg-turbo-dev \
      libressl-dev \
      make \
      musl-dev \
      postgresql-dev \
      python3-dev \
      zlib-dev \
    # Prepare virtual environment and install Synapse
    && virtualenv -p /usr/bin/python3 /opt/synapse \
    && set +x && . /opt/synapse/bin/activate && set -x \
    && pip3 install --requirement requirements.txt \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 synapse \
    && ctutil directory -u synapse -g synapse -m 0700 \
      /cts/synapse/persistent \
      /cts/synapse/volatile \
    # Uninstall build dependencies
    && apk del --purge --no-cache .build-deps \
    && true

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

USER 2000
EXPOSE 8008/tcp
VOLUME [ "/cts/synapse/persistent", "/cts/synapse/volatile" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]