#!/bin/sh
#shellcheck shell=ash
set -euo pipefail
. /usr/local/lib/scp

scp_prepare_dir "/cts/traefik/config" "traefik:traefik" "0700"
scp_prepare_dir "/cts/traefik/data" "traefik:traefik" "0700"

if [ "${#}" -ge 1 ]; then
    scp_runas "traefik" traefik "${@}"
else
    scp_runas "traefik" traefik \
        --api=true --ping=true \
        --entryPoints.traefik.address=":8081" \
        --providers.file.directory="/cts/traefik/config" \
        --providers.file.watch=true
fi
