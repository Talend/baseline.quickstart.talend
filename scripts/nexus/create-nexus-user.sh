#!/usr/bin/env bash

set -e
set -u
set -x

declare userid="${1:-}"
declare password="${2:-}"
declare email="${3:-}"
declare role="${4:-nx-admin}"
declare firstname="${5:-Talend}"
declare lastname="${6:-Administrator}"

declare usage="./create-nexus-user.sh <userid> <password> <email> <role> <firstname> <lastname>"

[ -z "${userid}" ] && echo "userid parameter required: ${usage}" 1>&2 && exit 1
[ -z "${password}" ] && echo "password parameter required: ${usage}" 1>&2 && exit 1
[ -z "${email}" ] && echo "email parameter required: ${usage}" 1>&2 && exit 1
[ -z "${role}" ] && echo "role parameter required: ${usage}" 1>&2 && exit 1

declare NEXUS_USERID=admin
declare NEXUS_PASSWORD=Talend123
declare NEXUS_HOST=localhost
declare NEXUS_PORT=8081

define(){ IFS=$'\n' read -r -d '' "${1}" || true; }

export create_user_message
define create_user_message <<EOF
{ "data": { "email":"${email}", "firstName":"${firstname}", "lastName":"${lastname}", "userId":"${userid}", "status":"active", "roles":["${role}"], "password":"${password}" } }
EOF
echo "create_user_message: ${create_user_message}" 1>&2


#curl -u "${NEXUS_USERID}:${NEXUS_PASSWORD}" "${NEXUS_HOST}:${NEXUS_PORT}/nexus/service/local/users"

curl -i -v \
    -H "Accept: application/json" \
    -H "Content-Type: application/json; charset=UTF-8" \
    -d "${create_user_message}" \
    -u "${NEXUS_USERID}:${NEXUS_PASSWORD}" \
    "${NEXUS_HOST}:${NEXUS_PORT}/nexus/service/local/users"
    
# delete the old admin user

curl -i -v \
    -H "Accept: application/json" \
    -H "Content-Type: application/json; charset=UTF-8" \
    -u "${userid}:${password}" \
    -X "DELETE" \
    "${NEXUS_HOST}:${NEXUS_PORT}/nexus/service/local/users/admin"
