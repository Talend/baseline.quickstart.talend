#!/usr/bin/env bash

set -u

[ "${FACTORY_ENV_FLAG:-0}" -gt 0 ] && return 0

export FACTORY_ENV_FLAG=1

factory_env_script_path=$(readlink -e "${BASH_SOURCE[0]}")
factory_env_script_dir="${factory_env_script_path%/*}"

source "${factory_env_script_dir}/../../util/util.sh"

function factory_env() {

    local factory_name="${factory_name:-${TALEND_FACTORY_NAME:-}}"
    local access_key="${access_key:-${TALEND_FACTORY_ACCESS_KEY:-}}"
    local secret_key="${secret_key:-${TALEND_FACTORY_SECRET_KEY:-}}"
    local talend_userid="${talend_userid:-${TALEND_FACTORY_TALEND_USERID:-}}"
    local talend_password="${talend_password:-${TALEND_FACTORY_TALEND_PASSWORD:-}}"
    local s3fs_url="${s3fs_url:-${TALEND_FACTORY_S3FS_URL:-https://github.com/s3fs-fuse/s3fs-fuse/archive/v1.82.tar.gz}}"
    local default_user="${default_user:-${TALEND_FACTORY_DEFAULT_USER:-}}"

    required access_key secret_key talend_userid talend_password

    license_env=license_env
    baseline_env=baseline_env
    quickstart_env=quickstart_env
    repo_env=repo_env
    java_env=java_env

    local region="us-east-1"

    local license_path="license"

    local tui_path="TUI-4.5.2.tar"
    local tui_profile="quickstart"

    while [ -z "${1}" ]; do
        shift
    done
    try "$@"
}

export -f factory_env
