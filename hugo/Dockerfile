FROM quay.io/snapserv/base-alpine:1.0.4@sha256:9b87e662728d9b111341504349607e6b266f359361ba435d669b1672dcd1b896

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
