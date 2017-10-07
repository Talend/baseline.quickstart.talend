#!/usr/bin/env bash

set -u

[ "${CREATE_BUCKET_FLAG:-0}" -gt 0 ] && return 0

export CREATE_BUCKET_FLAG=1

create_bucket_script_path=$(readlink -e "${BASH_SOURCE[0]}")
create_bucket_script_dir="${create_bucket_script_path%/*}"

# shellcheck source=../util/util.sh
source "${create_bucket_script_dir}/../util/util.sh"
# shellcheck source=../util/string_util.sh
source "${create_bucket_script_dir}/../util/string_util.sh"


function create_bucket_usage() {

    cat 1>&2 <<-EOF

	create_bucket <bucket> [ <region> ]

	parameters:
	    bucket
	    region

	constraints:
	    aws s3 cli configured with credentials

	Create an arbitrary bucket

	EOF
}


function create_bucket() {

    if [ "${1:-}" == "--help" ] || [ "${1:-}" == "-h" ]; then
        create_bucket_usage
        return 0
    fi

    local bucket="${1:-${bucket:-}}"

    required bucket

    local region="${2:-${region:-${TALEND_FACTORY_REGION:-}}}"

    [ -z "${region}" ] && region=$(aws configure get region)
    local -a regioncmd
    [ -n "${region}" ] && regioncmd=( "--region" "${region}" )

    local bucket_status
    bucket_status=$(aws s3api head-bucket --bucket "${bucket}" 2>&1 || true)
    debugLog "bucket_status=${bucket_status}"
    string_contains "${bucket_status}" "Not Found" && bucket_exists=1 || bucket_exists=0
    debugLog "bucket_exists=${bucket_exists}"
    [ "${bucket_exists}" == 0 ] && [ -n "${bucket_status}" ] && errorMessage "Bucket ${bucket} is not writable: ${bucket_status}" && return 1
    [ "${bucket_exists}" == 0 ] && debugLog "using existing bucket '${bucket}'" && return 0
    [ "${bucket_exists}" != 0 ] && debugLog "creating bucket ${bucket}" && aws s3 mb "s3://${bucket}" "${regioncmd[@]}" && return 0
    errorMessage "unexpected branch condition"
    return 1
}
