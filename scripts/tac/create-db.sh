#!/usr/bin/env bash

set -e
set -u

declare create_tac_db_script_path=$(readlink -e "${BASH_SOURCE[0]}")
declare create_tac_db_script_dir="${create_tac_db_script_path%/*}"

declare usage="create-tac-db.sh <mysql_host> <mysql_master_user> <mysql_master_password> <database> <database_user> <database_password>"

declare mysql_host="${1:-}"
declare mysql_master_user="${2:-}"
declare mysql_master_password="${3:-}"
declare database="${4:-}"
declare database_user="${5:-}"
declare database_password="${6:-}"

[ -z "${mysql_host}" ] && echo "missing mysql_host argument: usage: ${usage}" && exit 1
[ -z "${mysql_master_user}" ] && echo "missing mysql_master_user argument: usage: ${usage}" && exit 1
[ -z "${mysql_master_password}" ] && echo "missing mysql_master_password argument" && exit 1
[ -z "${database}" ] && echo "missing database argument: usage: ${usage}" && exit 1
[ -z "${database_user}" ] && echo "missing database_user argument: usage: ${usage}" && exit 1
[ -z "${database_password}" ] && echo "missing database_password argument: usage: ${usage}" && exit 1


define(){ IFS=$'\n' read -r -d '' "${1}" || true; }

# wrap tadcdb in backtick quotes for mysql
# do this outside of here document to avoid execution
database="\`${database}\`"

declare create_sql
define create_sql <<EOF
CREATE DATABASE IF NOT EXISTS ${database};
GRANT ALL ON ${database}.* to '${database_user}'@'%' IDENTIFIED BY '${database_password}';
EOF

mysql -h "${mysql_host}" -u "${mysql_master_user}" "-p${mysql_master_password}" <<< "${create_sql}"
