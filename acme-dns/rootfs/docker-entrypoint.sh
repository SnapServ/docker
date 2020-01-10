#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

ctutil template /etc/acme-dns/config.tmpl=/cts/acme-dns/acme-dns.cfg

exec /usr/local/bin/acme-dns \
    -c "/cts/acme-dns/acme-dns.cfg" \
    "${@}"
