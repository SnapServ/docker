#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

ctutil directory -u gitea -g gitea -m 0700 \
  /cts/gitea/persistent/data \
  /cts/gitea/persistent/home
ctutil template /etc/gitea/app.ini.tmpl=/cts/gitea/persistent/data/app.ini

exec ctutil run -p gitea -- gitea web \
    --config "/cts/gitea/persistent/data/app.ini" \
    --custom-path "/cts/gitea/persistent/data" \
    "${@}"
