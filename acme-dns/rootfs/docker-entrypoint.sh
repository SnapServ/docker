#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

ctutil template /etc/acme-dns/config.tmpl=/cts/acme-dns/volatile/acme-dns.cfg

ls -la /cts/acme-dns/volatile

exec ctutil run -p acme-dns -- /usr/local/bin/acme-dns \
    -c "/cts/acme-dns/volatile/acme-dns.cfg" \
    "${@}"
