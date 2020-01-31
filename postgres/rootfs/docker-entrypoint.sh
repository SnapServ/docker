#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

postgres_initialize() {
  ctutil run -p postgres -- initdb \
    --auth-local="trust" \
    --auth-host="scram-sha-256" \
    --locale="en_US.UTF-8" \
    --encoding="UTF8"

  postgres_config "unix_socket_directories" "'/cts/postgres/volatile'"
  postgres_config "password_encryption" "'scram-sha-256'"
  postgres_config "listen_addresses" "'*'"
}

postgres_config() {
  local _key="${1}"
  local _value="${2}"

  sed -Ei \
    -e '/^\s*('"${_key}"')\s*=.*/{s~~\1 = '"${_value}"'~;:a;n;ba;q}' \
    -e '$a'"${_key}"' = '"${_value}" \
    "${PGDATA}/postgresql.conf"
}

postgres_server_start() {
  local _attempt

  # Start temporary server process in background
  ctutil log "starting temporary database server..."
  (
    ctutil run -p postgres -- postgres -c 'listen_addresses='
  ) &

  # Attempt to connect to database up to 30 times
  for _attempt in $(seq 1 30); do
    ctutil log "waiting for database to be ready... [attempt %d of 30]" "${_attempt}"
    if echo "SELECT 1" | postgres_query >/dev/null 2>&1; then
      ctutil log "successfully started temporary database server"
      return
    fi
    sleep 1
  done

  # Connection to database has failed, abort
  ctutil log "could not start temporary database server, attempting to stop..."
  postgres_server_stop || true
  ctutil log "now exiting due to startup failure"
  exit 1
}

postgres_server_stop() {
  if pg_ctl stop; then
    ctutil log "successfully stopped temporary database server"
  else
    ctutil log "could not stop temporary database server"
    exit 1
  fi
}

postgres_account() {
  local _username="${1}"
  local _password="${2}"
  local _database="${_username}"

  postgres_query <<-EOQ
  CREATE DATABASE "${_database}";
  CREATE USER "${_username}" WITH ENCRYPTED PASSWORD '${_password}';
  GRANT ALL PRIVILEGES ON DATABASE "${_database}" TO "${_username}";
EOQ
}

# shellcheck disable=SC2120
postgres_query() {
  ctutil run -p postgres -- psql "${@}"
}

POSTGRES_PASSWORD="$(ctutil secret "POSTGRES_PASSWORD")"

if [ ! -f "/cts/postgres/persistent/PG_VERSION" ]; then
  ctutil log "no data directory found, initializing database..."
  postgres_initialize
  postgres_server_start
  postgres_account "${POSTGRES_USERNAME}" "${POSTGRES_PASSWORD}"
  postgres_server_stop
  ctutil log "successfully initialized postgres, starting server..."
else
  ctutil log "starting server with existing data directory..."
fi

exec ctutil run -p postgres -- postgres
