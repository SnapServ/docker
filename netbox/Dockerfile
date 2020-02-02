FROM quay.io/snapserv/base-alpine:1.1.11@sha256:687154bc9982b227224c33a95b2d8bd20204791ca929bcb939eabf4c5ee46a4c

ARG NETBOX_VERSION=2.7.3
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /opt/netbox
COPY rootfs/docker-requirements.txt /

RUN true \
    # Install runtime dependencies
    && apk add --no-cache \
        py3-virtualenv \
        python3 \
    # Install build dependencies
    && apk add --no-cache --virtual .build-deps \
        gcc \
        git \
        libjpeg-turbo-dev \
        musl-dev \
        postgresql-dev \
        python3-dev \
        zlib-dev \
    # Install Netbox and dependencies
    && git clone -b "v${NETBOX_VERSION}" https://github.com/netbox-community/netbox.git . \
    && virtualenv -p /usr/bin/python3 venv \
    && set +x && . venv/bin/activate && set -x \
    && pip3 install --requirement /docker-requirements.txt \
    && pip3 install --requirement requirements.txt \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 netbox \
    && ctutil directory -u netbox -g netbox -m 0700 \
        /cts/netbox/persistent \
        /cts/netbox/persistent/media \
    && ln -sf /cts/netbox/persistent/configuration.py /opt/netbox/netbox/netbox/configuration.py \
    # Uninstall build dependencies
    && apk add --no-cache $(ctutil elf-deps /opt/netbox | awk '{print "so:"$1}') \
    && apk del --purge --no-cache .build-deps \
    && true

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

USER 2000
EXPOSE 8080/tcp
VOLUME [ "/cts/netbox/persistent" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
