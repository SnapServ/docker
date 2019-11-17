#!/bin/sh
#shellcheck shell=ash
set -euo pipefail
. /usr/local/lib/scp

scp_runas "traefik" traefik "${@}"
