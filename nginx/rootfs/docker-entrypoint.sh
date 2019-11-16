#!/bin/sh
#shellcheck shell=ash
set -euo pipefail
. /usr/local/lib/scp

scp_prepare_dir "/run/nginx" "nginx:nginx" "0700"
scp_prepare_dir "/tmp/nginx" "nginx:nginx" "0700"
scp_certificate "nginx:nginx" "/run/nginx/ssl.crt" "/run/nginx/ssl.key"

scp_runas nginx "nginx" -g "daemon off;"
