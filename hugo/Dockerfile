FROM quay.io/snapserv/base-alpine:1.0.9@sha256:e80dfe9b9999d72ddf8aed7b3a460dc1ed97485f8bfd6c5bcc3871f07a26af99

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
