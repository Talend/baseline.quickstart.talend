#!/usr/bin/env bash

set -u

[ "${JAVA_ENV_FLAG:-0}" -gt 0 ] && return 0

export JAVA_ENV_FLAG=1


function java_env() {

    local java_type="${TALEND_FACTORY_JAVA_TYPE:-jre}"
    local java_major_version="${TALEND_FACTORY_JAVA_MAJOR_VERRSION:-8}"
    local java_minor_version="${TALEND_FACTORY_JAVA_MINOR_VERSION:-144}"
    local java_build="${TALEND_FACTORY_JAVA_BUILD:-b01}"
    local java_guid="${TALEND_FACTORY_JAVA_GUID:-/opt/java}"
    local java_repo_dir="${TALEND_FACTORY_JAVA_REPO_DIR:-/opt/repo/dependencies}"
    local java_target_dir="${TALEND_FACTORY_JAVA_TARGET_DIR:-/opt/java}"

    # sample file name: jre-8u144-linux-x64.tar.gz
    # sample unzip dir: jre1.8.0_144

    local java_filename_version="${java_major_version}u${java_minor_version}"
    local java_filename="${java_type}-${java_filename_version}-linux-x64.tar.gz"

    local java_full_version="1.${java_major_version}.0_${java_minor_version}"
    local java_unzip_dir="${java_type}${java_full_version}"

    while [ -z "${1}" ]; do
        shift
    done
    "$@" || die "cannot $*"
}

export -f java_env
