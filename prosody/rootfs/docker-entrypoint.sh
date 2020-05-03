#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

ctutil directory -m 0700 \
  /cts/prosody/volatile/run
ctutil template /etc/prosody/prosody.cfg.lua.tmpl=/cts/prosody/persistent/prosody.cfg.lua

exec ctutil run -p prosody -- prosody
