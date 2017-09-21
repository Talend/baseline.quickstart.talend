#!/usr/bin/env bash

set -e
set -u

[ "${#}" -ne 1 ] && echo "usage: create-nexus-env <target-path>" && exit 1

target_path="${1}"

script_path=$(readlink -e "${BASH_SOURCE[0]}")
script_dir="${script_path%/*}"

[ ! -e "${script_dir}/ec2-metadata" ] && echo "ec2-metadata script must be in the same directory as create-nexus-env.sh" && exit 1

echo "export TALEND_NEXUS_HOST=0.0.0.0" >> "${target_path}"
