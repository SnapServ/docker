#!/bin/sh
#shellcheck shell=ash
set -euo pipefail
. /usr/local/lib/scp

scp_prepare_dir "/cts/traefik/config" "traefik:traefik" "0700"
scp_prepare_dir "/cts/traefik/data" "traefik:traefik" "0700"

scp_runas "traefik" traefik "${@}"
