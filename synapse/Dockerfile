FROM quay.io/snapserv/base-alpine:1.1.15@sha256:34f27840f7c7aa20a7b78ea2a9167daa8a690b19c71e40547b68216ba5266318

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /opt/synapse
COPY rootfs/docker-requirements.txt /

RUN true \
    # Install runtime dependencies
    && apk add --no-cache \
        py3-virtualenv \
        python3 \
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
    && pip3 install --requirement /docker-requirements.txt \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 synapse \
    && ctutil directory -u synapse -g synapse -m 0700 \
        /cts/synapse/persistent \
        /cts/synapse/volatile \
    # Uninstall build dependencies
    && apk add --no-cache $(ctutil elf-deps /opt/synapse | awk '{print "so:"$1}') \
    && apk del --purge --no-cache .build-deps \
    && true

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

USER 2000
EXPOSE 8008/tcp
VOLUME [ "/cts/synapse/persistent", "/cts/synapse/volatile" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
