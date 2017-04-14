#!/bin/bash

set -e

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if ! grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then
        DB_ARGS+=("--${param}")
        DB_ARGS+=("${value}")
   fi;
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

# ODOO_CONFIGURATION_FILE=/etc/odoo/odoo.conf
# ODOO_GROUP="odoo"
# ODOO_DATA_DIR=/var/lib/odoo
# ODOO_LOG_DIR=/var/log/odoo
# ODOO_USER="odoo"

# allow the container to be started with `--user`
if [ "$1" = 'odoo' ] && [ "$(id -u)" = '0' ]; then
	mkdir -p "$ODOO_DATA_DIR"
	chown -R odoo "$ODOO_DATA_DIR"
	chmod 0750 "$ODOO_DATA_DIR"

    mkdir -p "$ODOO_CONFIGURATION_DIR"
	chown -R odoo "$ODOO_CONFIGURATION_DIR"
	chmod 0750 "$ODOO_CONFIGURATION_DIR"

    chown odoo "$ODOO_CONFIGURATION_FILE"
    chmod 0640 "$ODOO_CONFIGURATION_FILE"


    mkdir -p "$ODOO_EXTRA_ADDONS"
	chown -R odoo "$ODOO_EXTRA_ADDONS"
	chmod 0750 "$ODOO_EXTRA_ADDONS"

    mkdir -p "$ODOO_LOG_DIR"
	chown -R odoo "$ODOO_LOG_DIR"
	chmod 0750 "$ODOO_LOG_DIR"

    exec service odoo restart
    exec gosu odoo "$BASH_SOURCE" "$@"

fi


if [ "$1" = 'odoo' ]; then
	mkdir -p "$ODOO_DATA_DIR"
	chown -R "$(id -u)" "$ODOO_DATA_DIR" 2>/dev/null || :
	chmod 0750 "$ODOO_DATA_DIR" 2>/dev/null || :

    mkdir -p "$ODOO_CONFIGURATION_DIR"
	chown -R "$(id -u)" "$ODOO_CONFIGURATION_DIR" 2>/dev/null || :
	chmod 0750 "$ODOO_CONFIGURATION_DIR" 2>/dev/null || :

	chown -R "$(id -u)" "$ODOO_CONFIGURATION_FILE" 2>/dev/null || :
	chmod 0640 "$ODOO_CONFIGURATION_FILE" 2>/dev/null || :

    mkdir -p "$ODOO_EXTRA_ADDONS"
	chown -R "$(id -u)" "$ODOO_EXTRA_ADDONS" 2>/dev/null || :
	chmod 0750 "$ODOO_EXTRA_ADDONS" 2>/dev/null || :

    mkdir -p "$ODOO_LOG_DIR"
	chown -R "$(id -u)" "$ODOO_LOG_DIR" 2>/dev/null || :
	chmod 0750 "$ODOO_LOG_DIR" 2>/dev/null || :

    
fi


case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            exec odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        exec odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1
