#!/usr/bin/env bash

set -e
set -u

[ "${#}" -ne 1 ] && echo "usage: create-tacamc-env <target-path>" && exit 1

target_path="${1}"

script_path=$(readlink -e "${BASH_SOURCE[0]}")
script_dir="${script_path%/*}"

# source path must reflect modified location during deployment
# shellcheck source=../../git/parse_git_url.sh
source "${script_dir}/../../baseline/git/parse_git_url.sh"

[ ! -e "${script_dir}/ec2-metadata" ] && echo "ec2-metadata script must be in the same directory as create-tacamc-env.sh" && exit 1

function parse_metadata_result() {
    local metadata="${1}"
    local value="${metadata#*: }"
    echo "${value}"
}

local_hostname=$(${script_dir}/ec2-metadata -h)
local_hostname=$(parse_metadata_result "${local_hostname}")
internal_hostname="${local_hostname}.ec2.internal"
local_ipv4=$(${script_dir}/ec2-metadata -o)
local_ipv4=$(parse_metadata_result "${local_ipv4}")
public_hostname=$(${script_dir}/ec2-metadata -p)
public_hostname=$(parse_metadata_result "${public_hostname}")
public_ipv4=$(${script_dir}/ec2-metadata -v)
public_ipv4=$(parse_metadata_result "${public_ipv4}")

if [ -z "${public_ipv4}" ] || [ "${public_ipv4}" == "not available" ] || [ -z "${public_hostname}" ] || [ "${public_hostname}" == "not available" ]; then
    echo export TALEND_TAC_HOST="${internal_hostname}" >> "${target_path}"
    echo export TALEND_MONITORING_HOST="${internal_hostname}" >> "${target_path}"
else
    echo export TALEND_TAC_HOST="${public_hostname}" >> "${target_path}"
    echo export TALEND_MONITORING_HOST="${public_hostname}" >> "${target_path}"
fi


declare git_protocol=''
declare git_host=''
declare git_port=''
declare git_path=''
declare git_repo=''
if [ "${TALEND_CREATE_GIT}" == "true" ]; then
    git_protocol="http"
    git_host="${GitLabHost}"
    git_port="80"
    git_path="${TALEND_GIT_USER}"
    git_repo="oodlejobs.git"
    declare git_url="${git_protocol}://${git_host}:${git_port}/${git_path}/${git_repo}"
    echo "export TALEND_GIT_URL=\"${git_url}\"" >> "${target_path}"
else
    parse_git_url "${TALEND_GIT_URL}" git_protocol git_host git_port git_path git_repo
    # TALEND_GIT_URL is already exported and is not empty in server.env
fi

echo "export TALEND_GIT_PROTOCOL=\"${git_protocol}\"" >> "${target_path}"
echo "export TALEND_GIT_HOST=\"${git_host}\"" >> "${target_path}"
echo "export TALEND_GIT_PORT=\"${git_port}\"" >> "${target_path}"
echo "export TALEND_GIT_REPO=\"${git_repo}\"" >> "${target_path}"

echo 'echo "server-env: tacamc finished"' >> "${target_path}"
