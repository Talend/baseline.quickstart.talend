#!/bin/bash

set -e
set -u

[ "${PARSE_GIT_FLAG:-0}" -gt 0 ] && return 0

export PARSE_GIT_FLAG=1

parse_git_script_path=$(readlink -e "${BASH_SOURCE[0]}")
parse_git_script_dir="${parse_git_script_path%/*}"

# shellcheck source=../../util/util.sh
source "${parse_git_script_dir}/../../util/util.sh"

INFO_LOG=true

function parse_git_url() {

    local git_url="${1:-}"
    local _git_protocol="${2:-}"
    local _git_host="${3:-}"
    local _git_port="${4:-}"
    local _git_path="${5:-}"
    local _git_repo="${6:-}"

    required git_url _git_protocol _git_host _git_path _git_repo
    infoVar git_url

    local git_protocol_result=${git_url%%:*}
    infoVar git_protocol_result
    assign "${_git_protocol}" "${git_protocol_result}"

    local git_host_result=${git_url#*://}
    git_host_result=${git_host_result%%/*}

    local git_port_result=${git_host_result#*:}
    if [ "${git_port_result}" == "${git_host_result}" ]; then
        if [ "${git_protocol,,}" == "http" ]; then
            git_port_result=80
        else
            git_port_result=443
        fi
    else
        git_host_result=${git_host_result%:*}
    fi
    assign "${_git_host}" "${git_host_result}"
    infoVar git_host_result
    assign "${_git_port}" "${git_port_result}"
    infoVar git_port_result

    local git_path_result=${git_url#*://}
    git_path_result=${git_path_result#*/}
    git_path_result=${git_path_result%/*}
    infoVar git_path_result
    assign "${_git_path}" "${git_path_result}"

    local git_repo_result=${git_url##*/}
    infoVar git_repo_result
    assign "${_git_repo}" "${git_repo_result}"
}

declare git_protocol=""
declare git_host=""
declare git_port=""
declare git_path=""
declare git_repo=""

parse_git_url https://github.com/EdwardOst/oodle-eost-us-east-2.git git_protocol git_host git_port git_path git_repo
echo "'$git_protocol' '$git_host' '$git_port' '$git_path' '$git_repo'"

#parse_git_url https://github.com/topgolf/user1/oodle-eost-us-east-2.git git_protocol git_host git_port git_path git_repo
#echo $git_protocol $git_host $git_port $git_path $git_repo

