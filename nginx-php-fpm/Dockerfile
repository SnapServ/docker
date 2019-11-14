FROM quay.io/snapserv/base-alpine:1.0.0

RUN true \
    && apk add --no-cache \
    curl \
    nginx \
    openssl \
    php7-fpm \
    && true

COPY rootfs /

RUN true \
    && chmod 0755 /docker-entrypoint.sh /docker-healthcheck.sh \
    && rm \
        /etc/nginx/conf.d/default.conf \
        /etc/php7/php-fpm.d/www.conf \
    && adduser -h /var/www/html -S -s /bin/false -G www-data www-data \
    && addgroup nginx tty \
    && addgroup www-data tty \
    \
    && . /usr/lib/scp \
    && scp_relocate /var/lib/nginx/logs /tmp/nginx \
    && true

EXPOSE 8443/tcp
ENTRYPOINT [ "/docker-entrypoint.sh" ]
