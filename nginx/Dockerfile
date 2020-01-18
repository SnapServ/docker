FROM quay.io/snapserv/base-alpine:1.1.9@sha256:5245bf05606d652078946f4fd234154059903b6705eee741c01ef005a4c5c5d6

RUN true \
    # Install nginx and remove unused defaults
    && apk add --no-cache nginx \
    && rm /etc/nginx/conf.d/default.conf \
    # Prepare container runtime environment
    && ctutil account -u 2000 -g 2000 www-data \
    && ctutil directory -u www-data -g www-data -m 0700 \
        /cts/nginx/volatile/log \
        /cts/nginx/volatile/run \
        /cts/nginx/volatile/tmp \
    # Adjust and relink default paths
    && ctutil directory -u www-data -g www-data -m 0750 /var/lib/nginx \
    && rm -f /var/lib/nginx/logs /var/lib/nginx/run \
    && ln -sf /cts/nginx/volatile/log /var/lib/nginx/logs \
    && ln -sf /cts/nginx/volatile/run /var/lib/nginx/run \
    && true

COPY rootfs /

USER www-data
EXPOSE 8080/tcp
VOLUME [ "/cts/nginx/volatile" ]

ENTRYPOINT [ "/usr/sbin/nginx" ]
CMD [ "-g", "daemon off;" ]
