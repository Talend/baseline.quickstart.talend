#!/usr/bin/env bash

set -e
set -u
set -o pipefail

[ "${REPO_ENV_FLAG:-0}" -gt 0 ] && return 0

export REPO_ENV_FLAG=1

function repo_env() {

    local repo_bucket="${repo_bucket:-${TALEND_FACTORY_REPO_BUCKET:-repo-quickstart-talend}}"
    local repo_region="${repo_region:-${TALEND_FACTORY_REPO_REGION:-us-east-1}}"
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
