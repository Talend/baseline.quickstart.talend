#!/usr/bin/env bash

set -e
set -u
set -o pipefail

[ "${BASELINE_ENV_FLAG:-0}" -gt 0 ] && return 0

export BASELINE_ENV_FLAG=1


function baseline_env() {

    local baseline_bucket="${baseline_bucket:-${TALEND_FACTORY_BASELINE_BUCKET:-baseline.quickstart.talend}}"
    local baseline_region="${baseline_region:-${TALEND_FACTORY_BASELINE_REGION:-us-east-1}}"

    local bucket="${baseline_bucket}"
    local region="${baseline_region}"

    local baseline_git_url="https://github.com/EdwardOst"
    local baseline_git_repo="baseline.quickstart.talend"
    local baseline_git_target="master"

    local git_url="${baseline_git_url}"
    local git_repo="${baseline_git_repo}"
    local git_target="${baseline_git_target}"

    local baseline_s3_bucket="${baseline_bucket}"
    local baseline_s3_path=""
    local baseline_s3_grant="read=uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers"

    local s3_bucket="${baseline_s3_bucket}"
    local s3_path="${baseline_s3_path}"
    local s3_grant="${baseline_s3_grant}"

    while [ -z "${1}" ]; do
        shift
    done
    "$@" || die "cannot $*"
}

export -f baseline_env
