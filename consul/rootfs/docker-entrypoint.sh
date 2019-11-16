#!/bin/sh
#shellcheck shell=ash
set -euo pipefail
. /usr/local/lib/scp

scp_prepare_dir "/cts/consul/config" "consul:consul" "0700"
scp_prepare_dir "/cts/consul/data" "consul:consul" "0700"

scp_runas "consul" consul agent \
    -config-dir "/cts/consul/config" \
    -data-dir "/cts/consul/data" \
    -client "::" -server \
    "${@}"
