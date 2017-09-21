#!/usr/bin/env bash

set -e
set -u
set -o pipefail

[ "${QUICKSTART_ENV_FLAG:-0}" -gt 0 ] && return 0

export QUICKSTART_ENV_FLAG=1


function quickstart_env() {

    # export TALEND_FACTORY_QUICKSTART_BUCKET=quickstart.aws.talend.com
    # export TALEND_FACTORY_QUICKSTART_REGION=us-east-1

    local quickstart_bucket="oodle.quickstart.talend"
    local quickstart_region="us-east-1"

    local bucket="${quickstart_bucket}"
    local region="${quickstart_region}"

    local quickstart_git_url="https://github.com/EdwardOst"
    local quickstart_git_repo="quickstart-datalake-cognizant-talend"
    local quickstart_git_target="develop"

    local git_url="${quickstart_git_url}"
    local git_repo="${quickstart_git_repo}"
    local git_target="${quickstart_git_target}"

    local quickstart_s3_bucket="${quickstart_bucket}"
    local quickstart_s3_path=""
    local quickstart_s3_grant="read=uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers"

    local s3_bucket="${quickstart_s3_bucket}"
    local s3_path="${quickstart_s3_path}"
    local s3_grant="${quickstart_s3_grant}"

    while [ -z "${1}" ]; do
        shift
    done
    "$@" || die "cannot $*"
}

export -f quickstart_env
