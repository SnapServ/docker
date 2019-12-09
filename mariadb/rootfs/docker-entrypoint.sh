#!/bin/sh
#shellcheck shell=ash
set -euo pipefail
. /usr/local/lib/scp

if [ "${GOSS:-}" = "yes" ]; then
    scp_warn "Using insecure credentials for test environment [GOSS=yes]"
    MARIADB_ROOT_PASSWORD="goss-insecure-root"
    MARIADB_USER_ACCOUNT="goss"
    MARIADB_USER_PASSWORD="goss-insecure-user"
fi

mariadb_prepare_data_dir() {
    scp_info "preparing data directories..."
    (
        scp_runas "mariadb" mysql_install_db \
            --rpm \
            --auth-root-authentication-method="socket"
    )
}

mariadb_query() {
    mysql "${@}"
}

mariadb_server_start() {
    local _attempt

    # Start temporary server process in background
    scp_info "starting temporary database server..."
    (
        scp_runas "mariadb" mysqld --skip-networking
    ) &

    # Attempt to connect to database up to 30 times
    for _attempt in $(seq 1 30); do
        scp_info "waiting for database to be ready... [attempt %d of 30]" "${_attempt}"
        if echo "SELECT 1" | mariadb_query >/dev/null 2>&1; then
            scp_info "successfully started temporary database server"
            return
        fi
        sleep 1
    done

    # Connection to database has failed, abort
    scp_error "could not start temporary database server, attempting to stop..."
    mariadb_server_stop || true
    scp_fatal "now exiting due to startup failure"
}

mariadb_initial_setup() {
    # Import timezone data into database
    scp_info "importing timezone data into database..."
    if mysql_tzinfo_to_sql /usr/share/zoneinfo | mariadb_query --database="mysql"; then
        scp_info "successfully imported timezone data into mariadb"
    else
        scp_fatal "could not import timezone data into mariadb"
    fi

    # Remove insecure defaults from database
    if mariadb_secure_defaults; then
        scp_info "removed insecure defaults from database"
    else
        scp_fatal "could not remove insecure defaults from database"
    fi

    # Create root account if configured
    if [ -n "${MARIADB_ROOT_PASSWORD:-}" ]; then
        if mariadb_create_root "${MARIADB_ROOT_PASSWORD}"; then
            scp_info "created root account with password authentication"
        else
            scp_fatal "could not create root account with password authentication"
        fi
    fi

    # Create user and database pair if configured
    if [ -n "${MARIADB_USER_ACCOUNT:-}" ] && [ -n "${MARIADB_USER_PASSWORD}" ]; then
        if mariadb_create_user "${MARIADB_USER_ACCOUNT}" "${MARIADB_USER_PASSWORD}"; then
            scp_info "created user and database pair [%s]" "${MARIADB_USER_ACCOUNT}"
        else
            scp_fatal "could not create user and database pair [%s]" "${MARIADB_USER_ACCOUNT}"
        fi
    fi
}

mariadb_secure_defaults() {
    mariadb_query <<-EOQ
    SET @@SESSION.SQL_LOG_BIN=0;
    DELETE FROM mysql.user WHERE user NOT IN ('root') OR host NOT IN ('localhost');
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
        scp_info "successfully stopped temporary database server"
    else
        scp_fatal "could not stop temporary database server"
    fi
}

scp_prepare_dir "/cts/mariadb/data" "mariadb:mariadb" "0750"
scp_prepare_dir "/run/mariadb" "mariadb:mariadb" "0700"
scp_prepare_dir "/tmp/mariadb" "mariadb:mariadb" "0700"

if [ $# -ge 1 ]; then
    scp_runas "mariadb" "${@}"
fi

if [ ! -d "/cts/mariadb/data/mysql" ]; then
    scp_info "no data directory found, initializing database..."
    mariadb_prepare_data_dir
    mariadb_server_start
    mariadb_initial_setup
    mariadb_server_stop
    scp_info "successfully initialized mariadb, starting server..."
else
    scp_info "starting server with existing data directory..."
fi

scp_runas "mariadb" mysqld
