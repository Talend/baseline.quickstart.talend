#!/usr/bin/env bash

set -u

user_id=$(id -u)

# requires sudo
[ "${user_id}" -ne 0 ] && echo "talend-gitlab-external-urlr.sh must be run as root" && exit 1


update_hosts_script_path=$(readlink -e "${BASH_SOURCE[0]}")
update_hosts_script_dir="${update_hosts_script_path%/*}"

# ec2-metadata script must be ini the same directory
[ ! -e "${update_hosts_script_dir}/ec2-metadata" ] && echo "ec2-metadata script must be in the same directory as create-instance-env.sh" && exit 1


function parse_metadata_result() {
    local metadata="${1}"
    local value="${metadata#*: }"
    echo "${value}"
}

public_hostname=$("${update_hosts_script_dir}/ec2-metadata" -p)
public_hostname=$(parse_metadata_result "${public_hostname}")

# update gitlab.rb external url

sed -i "s|^external_url.*|external_url 'http://${public_hostname}'|g" /etc/gitlab/gitlab.rb
