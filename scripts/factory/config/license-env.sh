#!/usr/bin/env bash

set -u

[ "${LICENSE_ENV_FLAG:-0}" -gt 0 ] && return 0

export LICENSE_ENV_FLAG=1


function license_env() {

    local license_bucket="license.${factory_name}.talend"
    local license_region="us-east-1"
    local license_owner="talend"

    local bucket="${license_bucket}"
    local region="${license_region}"

    while [ -z "${1}" ]; do
        shift
    done
    "$@" || die "cannot $*"
}

export -f license_env
