#!/bin/sh
#shellcheck shell=ash
set -euo pipefail
. /usr/lib/scp

scp_prepare_dir "/run/nginx" "nginx:www-data" "0700"
scp_prepare_dir "/tmp/nginx" "nginx:www-data" "0700"
scp_prepare_dir "/run/php7" "www-data:www-data" "0750"

(
    umask 077

    _cert_host="$(hostname)"
    scp_info "generating self-signed ssl-certificate for %s" "${_cert_host}"
    openssl req -x509 -nodes -days 3650 \
        -subj "/CN=${_cert_host}" \
        -addext "subjectAltName=DNS:${_cert_host},DNS:localhost" \
        -newkey rsa:2048 -keyout /run/nginx/ssl.key \
        -out /run/nginx/ssl.crt
    chown "nginx:www-data" /run/nginx/ssl.crt /run/nginx/ssl.key
)

exec multirun \
    'scp-runas "nginx" nginx -g "daemon off;"' \
    'scp-runas "www-data" php-fpm7 -F'
