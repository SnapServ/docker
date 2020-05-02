#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

if [ ! -d /cts/routinator/persistent/repository ]; then
  ctutil log "no repository cache found, initializing routinator..."
  ctutil run -p routinator -- routinator \
    --base-dir="/cts/routinator/persistent" \
    init --force --accept-arin-rpa
fi

exec ctutil run -p routinator -- routinator \
  --base-dir="/cts/routinator/persistent" -v \
  server --rtr="[::]:3323" --http="[::]:9556"
