#!/bin/sh
#shellcheck shell=ash
set -euo pipefail

MARIADB_ROOT_PASSWORD="$(ctutil secret "MARIADB_ROOT_PASSWORD")"
MARIADB_USER_PASSWORD="$(ctutil secret "MARIADB_USER_PASSWORD")"

mariadb_prepare_data_dir() {
    ctutil log "preparing data directories..."
    (
        ctutil run -p mariadb -- mysql_install_db \
            --rpm \
            --auth-root-socket-user="mariadb" \
            --auth-root-authentication-method="socket"
    )
}

mariadb_query() {
    mysql "${@}"
}

mariadb_server_start() {
    local _attempt

    # Start temporary server process in background
    ctutil log "starting temporary database server..."
    (
        ctutil run -p mariadb -- mysqld --skip-networking
    ) &

    # Attempt to connect to database up to 30 times
    for _attempt in $(seq 1 30); do
        ctutil log "waiting for database to be ready... [attempt %d of 30]" "${_attempt}"
        if echo "SELECT 1" | mariadb_query >/dev/null 2>&1; then
            ctutil log "successfully started temporary database server"
            return
        fi
        sleep 1
    done

    # Connection to database has failed, abort
    ctutil log "could not start temporary database server, attempting to stop..."
    mariadb_server_stop || true
    ctutil log "now exiting due to startup failure"
    exit 1
}

mariadb_initial_setup() {
    # Import timezone data into database
    ctutil log "importing timezone data into database..."
    if mysql_tzinfo_to_sql /usr/share/zoneinfo | mariadb_query --database="mysql"; then
        ctutil log "successfully imported timezone data into mariadb"
    else
        ctutil log "could not import timezone data into mariadb"
        exit 1
    fi

    # Remove insecure defaults from database
    if mariadb_secure_defaults; then
        ctutil log "removed insecure defaults from database"
    else
        ctutil log "could not remove insecure defaults from database"
        exit 1
    fi

    # Create root account if configured
    if [ -n "${MARIADB_ROOT_PASSWORD:-}" ]; then
        if mariadb_create_root "${MARIADB_ROOT_PASSWORD}"; then
            ctutil log "created root account with password authentication"
        else
            ctutil log "could not create root account with password authentication"
            exit 1
        fi
    fi

    # Create user and database pair if configured
    if [ -n "${MARIADB_USER_ACCOUNT:-}" ] && [ -n "${MARIADB_USER_PASSWORD}" ]; then
        if mariadb_create_user "${MARIADB_USER_ACCOUNT}" "${MARIADB_USER_PASSWORD}"; then
            ctutil log "created user and database pair [%s]" "${MARIADB_USER_ACCOUNT}"
        else
            ctutil log "could not create user and database pair [%s]" "${MARIADB_USER_ACCOUNT}"
            exit 1
        fi
    fi
}

mariadb_secure_defaults() {
    mariadb_query <<-EOQ
    SET @@SESSION.SQL_LOG_BIN=0;
    DELETE FROM mysql.user WHERE user NOT IN ('mariadb') OR host NOT IN ('localhost');
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
    FLUSH PRIVILEGES;
EOQ
}

mariadb_create_root() {
    local _password="${1}"

    mariadb_query <<-EOQ
    CREATE USER 'root'@'%' IDENTIFIED BY '${_password}';
    GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;
EOQ
}

mariadb_create_user() {
    local _username="${1}"
    local _password="${2}"
    local _database="${_username}"

    mariadb_query <<-EOQ
    CREATE DATABASE IF NOT EXISTS \`${_database}\`;
    CREATE USER '${_username}'@'%' IDENTIFIED BY '${_password}';
    GRANT ALL ON \`${_database}\`.* TO '${_username}'@'%';
EOQ
}

mariadb_server_stop() {
    if mysqladmin shutdown; then
        ctutil log "successfully stopped temporary database server"
    else
        ctutil log "could not stop temporary database server"
        exit 1
    fi
}

if [ $# -ge 1 ]; then
    exec ctutil run -p mariadb -- "${@}"
fi

if [ ! -d "/cts/mariadb/persistent/data/mysql" ]; then
    ctutil log "no data directory found, initializing database..."
    mariadb_prepare_data_dir
    mariadb_server_start
    mariadb_initial_setup
    mariadb_server_stop
    ctutil log "successfully initialized mariadb, starting server..."
else
    ctutil log "starting server with existing data directory..."
fi

exec ctutil run -p mariadb -- mysqld
