#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

exec ctutil run -p redis -- redis-server \
  --bind "0.0.0.0" "::" \
  --protected-mode "no" \
  --dir "/cts/redis/persistent" \
  "${@}"
