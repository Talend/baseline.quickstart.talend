#!/usr/bin/env bash

[ "${JRE_INSTALLER_FLAG:-0}" -gt 0 ] && return 0

export JRE_INSTALLER_FLAG=1

jre_installer_script_path=$(readlink -e "${BASH_SOURCE[0]}")
jre_installer_script_dir="${jre_installer_script_path%/*}"

# shellcheck source=../util/util.sh
source "${jre_installer_script_dir}/../util/util.sh"

set -u


function is_java_installed() {
    local current_version
    current_version=$(java -version 2>&1)
    local installed_version
    installed_version=$(echo "${current_version}" | grep "build 1.8.0_" | wc -l)

    [ "${installed_version}" -gt 0 ] && return 0 || return 1
}

# openjdk signature
#
# java version "1.7.0_141"
# OpenJDK Runtime Environment (amzn-2.6.10.1.73.amzn1-x86_64 u141-b02)
# OpenJDK 64-Bit Server VM (build 24.141-b02, mixed mode)

# oracle jdk signature
#
# java version "1.8.0_144"
# Java(TM) SE Runtime Environment (build 1.8.0_144-b01)
# Java HotSpot(TM) 64-Bit Server VM (build 25.144-b01, mixed mode)



function get_java_version() {

    local current_version
    current_version=$(java -version 2>&1)

    current_version="${current_version#*\(build 1.8.0_}"
    current_version="${current_version%%)*}"
    debugLog "current_version=${current_version}"
    local minor_version="${current_version%-*}"
    debugLog "minor_version=${minor_version}"
    echo "${minor_version}"
}


function find_java_home() {
    local which_java
    which_java="$(which java)"
    local java_exists="${?}"
    if [ "${java_exists}" == 0 ]; then
        local java_path
        java_path=$(readlink -e "${which_java}")
        local java_bin_dir="${java_path%/*}"
        local jre_dir="${java_bin_dir%/*}"
        local jre_folder="${jre_dir##*/}"
        local java_prefix="${jre_folder:0:3}"
        if [ "${java_prefix,,}" == "jdk" ]; then
            JAVA_HOME="${jre_dir}"
            return 0
        else
            local jdk_dir="${jre_dir%/*}"
            local jdk_folder="${jdk_dir##*/}"
            local jdk_prefix="${jdk_folder:0:3}"
            if [ "${jdk_prefix,,}" == "jdk" ]; then
                JAVA_HOME="${jdk_dir}"
                return 0
            elif [ "${JDK_REQUIRED,,}" == "true" ]; then
                return 1
            else
                JAVA_HOME="{jdk_dir}"
                return 0
            fi
        fi
    else
        return 1
    fi
}


function download_java() {

    local java_filename_version="${1:-8u144}"
    local java_build="${2:-b01}"
    local java_guid="${3:-090f390dda5b47b9b721c7dfaa008135}"
    local java_type="${4:-jre}"
    local java_filename_version="${5:-8u144}"
    local java_target_dir="${6:-$(pwd)}"

    # sample url: http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jre-8u144-linux-x64.tar.gz
    wget --no-cookies --no-check-certificate --no-clobber \
         --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
         --directory-prefix="${java_target_dir}" \
         "http://download.oracle.com/otn-pub/java/jdk/${java_filename_version}-${java_build}/${java_guid}/${java_type}-${java_filename_version}-linux-x64.tar.gz"
}


function jre_installer_install_usage() {

    cat 1>&2 <<EOF

usage:
    jre-installer.sh [ <java_type> <java_major_version> <java_minor_version> <java_build> <java_guid> [ <java_repo_dir> [ <java_target_dir> ] ] ]

   jre-installer.sh
   jre-installer.sh jre 8 144 b01 090f390dda5b47b9b721c7dfaa008135
   jre-installer.sh jre 8 144 b01 090f390dda5b47b9b721c7dfaa008135 /opt/repo/dependencies
   jre-installer.sh jre 8 144 b01 090f390dda5b47b9b721c7dfaa008135 /opt/repo/dependencies /opt/java

if the java tgz file is not found in the repo directory it will attempt to download it from Oracle
EOF

}

function jre_installer_install() {

    [ "${#}" -ne 0 ] && [ "${#}" -ne 1 ] && [ "${#}" -ne 5 ] && [ "${#}" -ne 6 ] && [ "${#}" -ne 7 ] && jre_installer_install_usage && return 1

    local java_type="${1:-${java_type:-${TALEND_FACTORY_JAVA_TYPE:-jre}}}"
    local java_major_version="${2:-${java_major_version:-${TALEND_FACTORY_JAVA_MAJOR_VERSION:-8}}}"
    local java_minor_version="${3:-${java_minor_version:-${TALEND_FACTORY_JAVA_MINOR_VERSION:-144}}}"
    local java_build="${4:-${java_build:-${TALEND_FACTORY_JAVA_BUILD:-b01}}}"
    local java_guid="${5:-${java_guid:-${TALEND_FACTORY_JAVA_GUID:-090f390dda5b47b9b721c7dfaa008135}}}"
    local java_repo_dir="${6:-${java_repo_dir:-${TALEND_FACTORY_JAVA_REPO_DIR:-/opt/repo/dependencies}}}"
    local java_target_dir="${7:-${java_target_dir:-${TALEND_FACTORY_JAVA_TARGET_DIR:-/opt/java}}}"

    java_type="${java_type,,}"
    [ "${java_type}" != "jdk" ] && [ "${java_type}" != "jre" ] && echo "Invalid java_type parameter: valid values: [ 'jdk' | 'jre' ]" && return 1

    # requires sudo
    [ "$(id -u)" -ne 0 ] && echo "jre_installer must be run as root" && return 1

    local current_version
    current_version=$(get_java_version)
    debugLog "current_version=${current_version}"
    local java8_installed
    java8_installed=$(echo "$current_version" | grep "1.8.0" | wc -l)
    if [ "${java8_installed}" -gt 0 ]; then
        [ ! "${java_minor_version}" -gt "${current_version}" ] && echo "Java '${current_version}' already installed" && return 0
    fi

    # sample file name: jre-8u144-linux-x64.tar.gz
    # sample unzip dir: jre1.8.0_144

    local java_filename_version="${java_major_version}u${java_minor_version}"
    local java_filename="${java_type}-${java_filename_version}-linux-x64.tar.gz"
    local java_tgz_path="${java_repo_dir}/${java_filename}"

    local java_full_version="1.${java_major_version}.0_${java_minor_version}"
    local java_unzip_dir="${java_type}${java_full_version}"

    mkdir -p "${java_target_dir}/${java_unzip_dir}"

    if [ ! -f "${java_tgz_path}" ]; then
        # sample url: http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jre-8u144-linux-x64.tar.gz
        debugLog "downloading java from oracle"
        download_java "${java_filename_version}" "${java_build}" "${java_guid}" "${java_type}" "${java_filename_version}" "${java_target_dir}"
    else
        debugLog "copying java from repo"
        /bin/cp -f "${java_tgz_path}" "${java_target_dir}"
    fi

    tar xzpf "${java_target_dir}/${java_filename}" --directory "${java_target_dir}"

    # update current environment
    export JAVA_HOME="/usr/bin/java_home"
    if [ "${java_type}" == "jdk" ]; then
        export JRE_HOME="${JAVA_HOME}/jre"
    else
        export JRE_HOME="${JAVA_HOME}"
    fi

    # append to environment file
    tee /etc/environment <<EOF
JAVA_HOME=${JAVA_HOME}
JRE_HOME=${JRE_HOME}
EOF

    # append to profile.d file
    tee /etc/profile.d/jre.sh <<EOF
export JAVA_HOME="${JAVA_HOME}"
export JRE_HOME="${JRE_HOME}"
EOF

    # add alternatives and set priorities
    update-alternatives --install /usr/bin/java_home java_home "${java_target_dir}/${java_type}${java_full_version}" 999 \
        --slave /usr/bin/java java "${java_target_dir}/${java_type}${java_full_version}/bin/java" \
        --slave /usr/bin/javac javac "${java_target_dir}/${java_type}${java_full_version}/bin/javac" \
        --slave /usr/bin/jar jar "${java_target_dir}/${java_type}${java_full_version}/bin/jar"

    # select active alternative
    update-alternatives --set java_home "${java_target_dir}/${java_type}${java_full_version}"
}
