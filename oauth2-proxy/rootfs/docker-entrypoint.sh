#!/bin/sh
#shellcheck shell=ash
set -euo pipefail
. /usr/local/lib/scp

if [ "${GOSS:-}" = "yes" ]; then
    scp_warn "Using insecure defaults for test environment [GOSS=yes]"
    export OAUTH2_PROXY_COOKIE_SECRET="${OAUTH2_PROXY_COOKIE_SECRET:-goss-insecure}"
    export OAUTH2_PROXY_CLIENT_ID="${OAUTH2_PROXY_CLIENT_ID:-goss-insecure}"
    export OAUTH2_PROXY_CLIENT_SECRET="${OAUTH2_PROXY_CLIENT_SECRET:-goss-insecure}"
    export OAUTH2_PROXY_EMAIL_DOMAINS="${OAUTH2_PROXY_EMAIL_DOMAINS:-example.com}"
fi

scp_runas "oauth2-proxy" oauth2-proxy \
    -http-address "[::]:4180" \
    -ping-path "/ping" \
    -silence-ping-logging \
    "${@}"
