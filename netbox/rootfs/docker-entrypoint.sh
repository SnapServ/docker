#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

. /opt/netbox/venv/bin/activate

ctutil directory -m 0700 \
  /cts/netbox/persistent/media
ctutil template /etc/netbox/configuration.py.tmpl=/cts/netbox/persistent/configuration.py

if [ $# -ge 1 ]; then
  cd /opt/netbox/netbox
  exec ctutil run -p netbox -- "${@}"
fi

exec ctutil run -p netbox -- gunicorn \
  --bind '[::]:8080' \
  --pythonpath '/opt/netbox/netbox' \
  --worker-class 'gthread' \
  --workers 2 \
  --threads 4 \
  --forwarded-allow-ips '*' \
  --access-logfile - \
  --error-logfile - \
  netbox.wsgi
