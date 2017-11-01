#!/usr/bin/env bash

set -e
set -u

[ "${#}" -ne 1 ] && echo "usage: create-jobserver-env <target-path>" && exit 1

target_path="${1}"

script_path=$(readlink -e "${BASH_SOURCE[0]}")
script_dir="${script_path%/*}"

[ ! -e "${script_dir}/ec2-metadata" ] && echo "ec2-metadata script must be in the same directory as create-jobserver-env.sh" && exit 1

function parse_metadata_result() {
    local metadata="${1}"
    local value="${metadata#*: }"
    echo "${value}"
}


TALEND_JOBSERVER_LABEL=$("${script_dir}/ec2-metadata" --local-hostname)
TALEND_JOBSERVER_LABEL="${TALEND_JOBSERVER_LABEL#*: }"
TALEND_JOBSERVER_LABEL="${TALEND_JOBSERVER_LABEL//./_}"
TALEND_JOBSERVER_LABEL="${TALEND_JOBSERVER_LABEL//-/_}"

local_ipv4=$("${script_dir}/ec2-metadata" -o)
local_ipv4=$(parse_metadata_result "${local_ipv4}")

#TALEND_JOBSERVER_FQDN=$(hostname -f)
TALEND_JOBSERVER_FQDN="${local_ipv4}"

echo "export TALEND_JOBSERVER_LABEL=${TALEND_JOBSERVER_LABEL}" >> "${target_path}"
echo "export TALEND_JOBSERVER_FQDN=${TALEND_JOBSERVER_FQDN}" >> "${target_path}"
