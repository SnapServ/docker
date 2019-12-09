#!/bin/sh
#shellcheck shell=ash
set -euo pipefail
. /usr/local/lib/scp

if [ "${GOSS:-}" = "yes" ]; then
    scp_warn "Using insecure secret key for test environment [GOSS=yes]"
    export GITEA_SECRET_KEY="${GITEA_SECRET_KEY:-goss-insecure}"
fi

scp_prepare_dir "/cts/gitea/data" "gitea:gitea" "0700"
scp_template -o "gitea:gitea" -m "0700" \
    "/etc/gitea/app.ini.gotmpl" "/cts/gitea/data/conf/app.ini"

scp_runas "gitea" gitea web \
    --config "/cts/gitea/data/conf/app.ini" \
    --custom-path "/cts/gitea/data" \
    "${@}"
