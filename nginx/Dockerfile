FROM quay.io/snapserv/base-alpine:1.0.4

RUN true \
    # Install required packages
    && apk add --no-cache \
    nginx \
    # Add system accounts and groups
    && adduser -h /var/www/html -S -s /bin/false -G www-data www-data \
    && addgroup nginx tty \
    && addgroup www-data tty \
    # Remove default configuration files
    && rm /etc/nginx/conf.d/default.conf \
    && true

COPY rootfs /

RUN true \
    # Mark entrypoint script as executable
    && chmod 0755 /docker-entrypoint.sh \
    # Relocate /var/lib/nginx/logs to tmp directory
    # Only needed during startup, actual logging is stdout/stderr
    && scp relocate /var/lib/nginx/logs /tmp/nginx \
    && true

EXPOSE 8443/tcp
ENTRYPOINT [ "/docker-entrypoint.sh" ]