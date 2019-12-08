FROM quay.io/snapserv/base-alpine:1.0.7@sha256:c70085949b4792b67d79ee4408002ac90d644b7f59a38208b1e3b02aa129e45d

RUN true \
    # Install required packages
    && apk add --no-cache \
    hugo \
    # Add system account and group
    && addgroup -S hugo \
    && adduser -h /usr/src/app -S -s /bin/false -G hugo hugo \
    # Prepare source and build directories
    && mkdir -p /usr/src/app /var/www/html \
    && chown hugo:hugo /usr/src/app /var/www/html \
    && true

COPY rootfs /
RUN chmod 0755 /docker-entrypoint.sh

WORKDIR /usr/src/app
ONBUILD COPY . /usr/src/app
ONBUILD RUN hugo --destination /var/www/html

EXPOSE 1313/tcp
ENTRYPOINT [ "/docker-entrypoint.sh" ]
