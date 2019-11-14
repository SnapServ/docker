#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

curl -sfk http://localhost:8443/fpm-ping
