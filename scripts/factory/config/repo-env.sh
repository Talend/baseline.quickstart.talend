#!/usr/bin/env bash

set -u

[ "${REPO_ENV_FLAG:-0}" -gt 0 ] && return 0

export REPO_ENV_FLAG=1

function repo_env() {

    local repo_bucket="repo-${factory_name}-talend"
    local repo_region="us-east-1"
    local repo_path="/"
    local repo_mount_dir="/opt/repo"

    local bucket="${repo_bucket}"
    local region="${repo_region}"

    string_contains "${repo-bucket}" "." && errorMessage "invalid repo bucket name '${bucket}', repo bucket name cannot contain periods" && return 1

    while [ -z "${1}" ]; do
        shift
    done
    "$@" || die "cannot $*"
}

export -f repo_env
