#!/bin/sh
#shellcheck shell=ash
set -euo pipefail
. /usr/local/lib/scp

scp_prepare_dir "/tmp/hugo" "hugo:hugo" "0700"

if [ $# -ge 1 ]; then
    scp_runas "hugo" hugo "${@}"
else
    scp_runas "hugo" hugo server \
        --bind=:: \
        --cacheDir=/tmp/hugo \
        --config=/etc/hugo-docker.toml,config.toml
fi
