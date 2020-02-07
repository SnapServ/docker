#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

ctutil directory -m 0700 \
  /cts/netbox/persistent/media \
  /cts/netbox/persistent/reports \
  /cts/netbox/persistent/scripts
ctutil template /etc/netbox/configuration.py.tmpl=/cts/netbox/persistent/configuration.py

if [ $# -ge 1 ]; then
  exec ctutil run -p netbox -- /opt/netbox/venv/bin/python \
    /opt/netbox/netbox/manage.py "${@}"
fi

exec ctutil run -p netbox -- /opt/netbox/venv/bin/gunicorn \
  --bind '[::]:8000' \
  --pythonpath '/opt/netbox/netbox' \
  --worker-class 'gthread' \
  --workers 2 \
  --threads 4 \
  --preload \
  --forwarded-allow-ips '*' \
  --access-logfile - \
  --error-logfile - \
  netbox.wsgi
