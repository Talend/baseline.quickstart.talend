#!/usr/bin/env bash

set -u

[ "${TALEND_FACTORY_FLAG:-0}" -gt 0 ] && return 0

export TALEND_FACTORY_FLAG=1

policy_script_path=$(readlink -e "${BASH_SOURCE[0]}")
policy_script_dir="${policy_script_path%/*}"

# shellcheck source=../util/util.sh
source "${policy_script_dir}/../util/util.sh"
# shellcheck source=../util/string_util.sh
source "${policy_script_dir}/../util/string_util.sh"


function policy_public_read() {

    local policy_ref="${1:-${policy_ref:-}}"
    local bucket="${2:-${bucket:-}}"

    required policy_ref bucket

    define "${policy_ref}" <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${bucket}/*"
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::${bucket}"
        }
    ]
}
EOF

}

export -f policy_public_read



function attach_policy() {

    local policy_file="${1:-${policy_file}}"
    local bucket="${2:-${bucket:-}}"

    required policy_file bucket

    aws s3api put-bucket-policy --bucket "${bucket}" --policy "file://${policy_file}"
}

export -f attach_policy

