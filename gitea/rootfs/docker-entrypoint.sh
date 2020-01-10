#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

ctutil template /etc/gitea/app.ini.gotmpl=/cts/gitea/persistent/data/app.ini

exec ctutil run -p gitea -- gitea web \
    --config "/cts/gitea/persistent/data/app.ini" \
    --custom-path "/cts/gitea/persistent/data" \
    "${@}"
