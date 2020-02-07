#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

exec ctutil run -p oauth2-proxy -- /usr/local/bin/oauth2-proxy \
  -http-address='[::]:4180' \
  -ping-path='/ping' \
  -silence-ping-logging \
  "${@}"
