#!/usr/bin/env bash

set -e
set -u
set -o pipefail

install_script_path=$(readlink -e "${BASH_SOURCE[0]}")
install_script_dir="${install_script_path%/*}"

# shellcheck source=../util/util.sh
source "${install_script_dir}/../util/util.sh"

# shellcheck source=../util/string_util.sh
source "${install_script_dir}/../util/string_util.sh"

# shellcheck source=./build.sh
source "${install_script_dir}/build.sh"

export WARNING_LOG=true
export INFO_LOG=true
export DEBUG_LOG=true

# requires sudo
[ "$(id -u)" -ne 0 ] && echo "install must be run as root" && exit


function get_factory_parms() {

    local factory_ref="${1}"

    required factory_ref

    local default_factory="${!factory_ref}"
    local factory_name
    read -rp "enter factory name [${default_factory}]: " factory_name
    trim factory_name
    factory_name="${!factory_name:-${default_factory}}"
    required factory_name
    assign "${factory_ref}" "${factory_name}"

    [ -f "${factory_name}.properties" ] && echo "using ${factory_name}.properties" && return 0

    read -rp "enter aws access key: " access_key
    read -rp "enter aws secret key: " secret_key
    read -rp "enter talend userid: " talend_userid
    read -rp "enter talend password: " talend_password
    read -rp "enter default user: " default_user

    local umask_save
    umask_save=$(umask)
    umask 377
    cat > "${factory_name}.properties" <<-EOF && true
	export TALEND_FACTORY_NAME="${factory_name}"
	export TALEND_FACTORY_ACCESS_KEY="${access_key}"
	export TALEND_FACTORY_SECRET_KEY="${secret_key}"
	export TALEND_FACTORY_TALEND_USERID="${talend_userid}"
	export TALEND_FACTORY_TALEND_PASSWORD="${talend_password}"
    export TALEND_FACTORY_DEFAULT_USER="${default_user}"
	EOF

   result="${?}"
   umask "${umask_save}"
   return "${result}"
}



function factory() {

    local factory_dir="${1:-${factory_dir:-${TALEND_FACTORY_NAME}}}"

    required factory_dir

    [ ! -d "${factory_dir}" ] && errorMessage "invalid argument: factory_dir '${factory_dir}' does not exist" && return 1

    debugLog "attempting to source ${factory_dir}"

    for script_file in "${factory_dir}"/*.sh ; do
        if [ -r "${script_file}" ]; then
            debugLog "soucing ${script_file}"
            # shellcheck source=/dev/null
            source "${script_file}"
        fi
    done

    factory_env build
}


declare quickstart_name="${1:-}"

required quickstart_name

get_factory_parms quickstart_name
echo "using ${quickstart_name}.properties"
source "${quickstart_name}.properties"

declare config_dir="${quickstart_name}"

if [ -d "${config_dir}" ]; then
    : # do nothing
elif [ -d "${install_script_dir}/${config_dir}" ]; then
    config_dir="${install_script_dir}/${config_dir}"
else
    config_dir="${install_script_dir}/config"
fi
infoLog "using config directory ${config_dir}" 1>&2

factory "${config_dir}"
