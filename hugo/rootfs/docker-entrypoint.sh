#!/bin/sh
#shellcheck shell=ash
set -euo pipefail
. /usr/local/lib/scp

scp_prepare_dir "/tmp/hugo" "hugo:hugo" "0700"
scp_prepare_dir "/tmp/hugo-quickstart" "hugo:hugo" "0700"

if [ $# -ge 1 ]; then
    scp_runas "hugo" hugo "${@}"
else
    if [ ! -f /usr/src/app/config.toml ]; then
        scp_warn "no config.toml in /usr/src/app found, generating empty quickstart page..."
        cd /tmp/hugo-quickstart
        ( scp_runas "hugo" hugo new site . )
    fi

    scp_runas "hugo" hugo server \
        --bind=:: \
        --cacheDir=/tmp/hugo \
        --config=/etc/hugo-docker.toml,config.toml
fi
