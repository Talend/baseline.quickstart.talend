#!/usr/bin/env bash

set -e
set -u

[ "${#}" -ne 1 ] && echo "usage: create-jobserver-env <target-path>" && exit 1

target_path="${1}"

script_path=$(readlink -e "${BASH_SOURCE[0]}")
script_dir="${script_path%/*}"

[ ! -e "${script_dir}/ec2-metadata" ] && echo "ec2-metadata script must be in the same directory as create-jobserver-env.sh" && exit 1

TALEND_JOBSERVER_LABEL=$("${script_dir}/ec2-metadata" --local-hostname)
TALEND_JOBSERVER_LABEL="${TALEND_JOBSERVER_LABEL#*: }"
TALEND_JOBSERVER_LABEL="${TALEND_JOBSERVER_LABEL//./_}"
TALEND_JOBSERVER_LABEL="${TALEND_JOBSERVER_LABEL//-/_}"

TALEND_JOBSERVER_FQDN=$(hostname -f)

echo "export TALEND_JOBSERVER_LABEL=${TALEND_JOBSERVER_LABEL}" >> "${target_path}"
echo "export TALEND_JOBSERVER_FQDN=${TALEND_JOBSERVER_FQDN}" >> "${target_path}"
