#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

ctutil template \
  /etc/synapse/synapse.yaml.tmpl=/cts/synapse/persistent/synapse.yaml \
  /etc/synapse/logger.yaml.tmpl=/cts/synapse/persistent/logger.yaml

ctutil run -p synapse -- /opt/synapse/bin/python3 -m synapse.app.homeserver \
  --config-path "/cts/synapse/persistent/synapse.yaml" \
  --data-directory "/cts/synapse/persistent" \
  --generate-missing-configs

exec ctutil run -p synapse -- /opt/synapse/bin/python3 -m synapse.app.homeserver \
  --config-path "/cts/synapse/persistent/synapse.yaml" \
  --data-directory "/cts/synapse/persistent" \
  "${@}"
