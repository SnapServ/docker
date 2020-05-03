FROM quay.io/snapserv/base-alpine:1.1.15@sha256:34f27840f7c7aa20a7b78ea2a9167daa8a690b19c71e40547b68216ba5266318

# renovate: datasource=github-tags depName=netbox-community/netbox
ENV NETBOX_VERSION="v2.7.3"

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
    && git clone -b "${NETBOX_VERSION}" https://github.com/netbox-community/netbox.git . \
    && virtualenv -p /usr/bin/python3 venv \
    && set +x && . venv/bin/activate && set -x \
    && pip3 install --requirement /docker-requirements.txt \
    && pip3 install --requirement requirements.txt \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 netbox \
    && ctutil directory -u netbox -g netbox -m 0700 \
        /cts/netbox/persistent \
        /cts/netbox/persistent/media \
        /cts/netbox/persistent/reports \
        /cts/netbox/persistent/scripts \
    && ln -sf /cts/netbox/persistent/configuration.py /opt/netbox/netbox/netbox/configuration.py \
    # Uninstall build dependencies
    && apk add --no-cache $(ctutil elf-deps /opt/netbox | awk '{print "so:"$1}') \
    && apk del --purge --no-cache .build-deps \
    && true

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

USER 2000
EXPOSE 8000/tcp
VOLUME [ "/cts/netbox/persistent" ]

ENTRYPOINT [ "/docker-entrypoint.sh" ]
