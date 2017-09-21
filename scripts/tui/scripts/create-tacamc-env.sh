#!/usr/bin/env bash

set -e
set -u

[ "${#}" -ne 1 ] && echo "usage: create-tacamc-env <target-path>" && exit 1

target_path="${1}"

script_path=$(readlink -e "${BASH_SOURCE[0]}")
script_dir="${script_path%/*}"

[ ! -e "${script_dir}/ec2-metadata" ] && echo "ec2-metadata script must be in the same directory as create-tacamc-env.sh" && exit 1

function parse_metadata_result() {
    local metadata="${1}"
    local value="${metadata#*: }"
    echo "${value}"
}

local_hostname=$(./ec2-metadata -h)
local_hostname=$(parse_metadata_result "${local_hostname}")
internal_hostname="${local_hostname}.ec2.internal"
local_ipv4=$(./ec2-metadata -o)
local_ipv4=$(parse_metadata_result "${local_ipv4}")
public_hostname=$(./ec2-metadata -p)
public_hostname=$(parse_metadata_result "${public_hostname}")
public_ipv4=$(./ec2-metadata -v)
public_ipv4=$(parse_metadata_result "${public_ipv4}")

if [ -z "${public_ipv4}" ] || [ "${public_ipv4}" == "not available" ] || [ -z "${public_hostname}" ] || [ "${public_hostname}" == "not available" ]; then
    echo export TALEND_MONITORING_HOST="${internal_hostname}" >> "${target_path}"
else
    echo export TALEND_MONITORING_HOST="${public_hostname}" >> "${target_path}"
fi

echo 'echo "server-env: tacamc finished"' >> "${target_path}"
