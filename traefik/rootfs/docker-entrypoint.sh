#!/bin/sh
#shellcheck shell=ash
set -euo pipefail
. /usr/local/lib/scp

scp_prepare_dir "/cts/traefik/config" "traefik:traefik" "0700"
scp_prepare_dir "/cts/traefik/data" "traefik:traefik" "0700"

scp_runas "traefik" traefik \
    --entryPoints.ping.address=":8081" \
    --ping.entryPoint="ping" \
    --providers.file.directory="/cts/traefik/config" \
    --providers.file.watch=true \
    "${@}"
