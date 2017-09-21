#!/usr/bin/env bash

set -e
set -u
set -o pipefail

[ "${LICENSE_ENV_FLAG:-0}" -gt 0 ] && return 0

export LICENSE_ENV_FLAG=1


function license_env() {

    local license_bucket="${license_bucket:-${TALEND_FACTORY_LICENSE_BUCKET:-license.quickstart.talend}}"
    local license_region="${license_region:-${TALEND_FACTORY_LICENSE_REGION:-us-east-1}}"
    local license_owner="talend"

    local bucket="${license_bucket}"
    local region="${license_region}"

    while [ -z "${1}" ]; do
        shift
    done
    "$@" || die "cannot $*"
}

export -f license_env
