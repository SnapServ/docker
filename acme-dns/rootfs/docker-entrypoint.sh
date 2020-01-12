#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

ctutil template /etc/acme-dns/config.tmpl=/cts/acme-dns/persistent/acme-dns.cfg

exec ctutil run -p acme-dns -- /usr/local/bin/acme-dns \
    -c "/cts/acme-dns/persistent/acme-dns.cfg" \
    "${@}"
