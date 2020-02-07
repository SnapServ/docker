#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

if [ $# -ge 1 ]; then
    exec ctutil run -p hugo -- hugo "${@}"
else
    if [ ! -f /cts/hugo/persistent/data/config.toml ]; then
        ctutil log "no config.toml found, generating empty quickstart page..."
        ctutil run -p hugo -- hugo new site .
    fi

    exec ctutil run -p hugo -- hugo server \
        --bind="::" \
        --cacheDir="/tmp" \
        --config="/etc/hugo-docker.toml,config.toml"
fi
