#!/usr/bin/env bash

set -e
set -u

[ "${#}" -ne 1 ] && echo "usage: create-instance-env <target-path>" && exit 1

target_path="${1}"

script_path=$(readlink -e "${BASH_SOURCE[0]}")
script_dir="${script_path%/*}"

[ ! -e "${script_dir}/ec2-metadata" ] && echo "ec2-metadata script must be in the same directory as create-instance-env.sh" && exit 1

function ec2_metadata_to_env() {
    # not included: "user-data"
    local -a keys=( "ami-id" "ami-launch-index" "ami-manifest-path" "ancestor-ami-ids" "block-device-mapping" "instance-id" "instance-type" "local-hostname" "local-ipv4" "kernel-id" "availability-zone" "product-codes" "public-hostname" "public-ipv4" "public-keys" "ramdisk-id" "reservation-id" "security-groups" "user-data" )

    local current_line value varname
    for property in "${keys[@]}"; do
        current_line=$("${script_dir}/ec2-metadata" "--${property}")
        value="${current_line#*: }"
		varname="${property^^}"
		varname="${varname//-/_}"
		printf "export %s=%q\n" "${varname}" "${value}"
    done
}
ec2_metadata_to_env >> "${target_path}"
