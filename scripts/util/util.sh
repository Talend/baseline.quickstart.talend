#!/usr/bin/env bash

set -u

[ "${UTIL_FLAG:-0}" -gt 0 ] && return 0

export UTIL_FLAG=1


#
# always be sure to quote both arguments when invoking this function, otherwise$
#
function assign() {
    local _var="${1}"
    local value="${2}"
    if ! required _var value; then
        echo "ERROR: ${BASH_SOURCE[1]##*/} ${BASH_LINENO[1]} : error in required parameters of function assign : ${FUNCNAME[*]:1}" 1>&2
        return 1
    fi
    if [ -z "${!_var+x}" ]; then
        echo "ERROR: ${BASH_SOURCE[1]##*/} ${BASH_LINENO[1]} : assign reference variable '${_var}' not defined prior to use : ${FUNCNAME[*]:1}" 1>&2
        return 1
    fi
    printf -v "${_var}" '%s' "${value}"
}


define(){
    IFS=$'\n' read -r -d '' "${1}" || true;
}


function warningLog() {
    [ -n "${WARNING_LOG:-}" ] && echo "WARNING: ${*} : ${FUNCNAME[*]:1}" 1>&2
    return 0
}


function infoLog() {
    [ -n "${INFO_LOG:-}" ] && echo "INFO: ${*} : ${FUNCNAME[*]:1}" 1>&2
    return 0
}


function infoVar() {
    [ -n "${INFO_LOG:-}" ] && [ -z "${!1+x}" ] && echo "INFO: ${FUNCNAME[*]:1} : undefined variable '${1}'" && return 0
    [ -n "${INFO_LOG:-}" ] && echo "INFO: ${1}=${!1}" 1>&2 && return 0
    return 0
}


function debugLog() {
    [ -n "${DEBUG_LOG:-}" ] && echo "DEBUG: ${FUNCNAME[*]:1} : ${*}" 1>&2
    return 0
}


function debugVar() {
    [ -n "${DEBUG_LOG:-}" ] && [ -z "${!1+x}" ] && echo "DEBUG: ${FUNCNAME[*]:1} : undefined variable '${1}'" && return 0
    [ -n "${DEBUG_LOG:-}" ] && echo "DEBUG: ${FUNCNAME[*]:1} : ${1}=${!1}" 1>&2 && return 0
    return 0
}


function debugStack() {
    if [ -n "${DEBUG_LOG:-}" ] ; then
        local args
        [ "${#}" -gt 0 ] && args=": $*"
        echo "DEBUG: ${FUNCNAME[*]:1}${args}" 1>&2
    fi
    return 0
}


function errorMessage() {
    echo "ERROR: ${BASH_SOURCE[-2]##*/} ${BASH_LINENO[-2]} : ${0} : ${FUNCNAME[$
}


function defined() {
    local arg
    local error_message=""
    for arg in "${@}"; do
        if [ -z "${!arg+x}" ]; then
            error_message="${error_message} undefined ${arg}"
        else
            debugLog "'${arg}' passed"
        fi
    done
    [ -n "${error_message}" ] \
        && error_message="missing required arguments:${error_message}" \
        && echo "$0: ${FUNCNAME[*]:1}: ${error_message}" 1>&2 \
        && return 1
    return 0
}


#
# TODO: error not triggering even with return code of 1
#
# required works fine when invoked by itself, but when
# it is invoked along with another test condition in the
# parent and the validation fails in the child function
# the child function error handler is not triggering.
#
# For example:
#
# Parent script calls a function
#
#     echo "## expect missing required argument bucket"
#     create_bucket "" "us-east-1" && true
#     echo "return ${?}"
#
# The parent script expects the child function to invoke
# the required function on the args and fail.  Since the
# parent script wants to continue processing it does an
# and operation expecting to test the return result
#
# In the child function the required invocation returns 1 but for
# some reason does not exit
#
#    function myfunc() {
#        required bucket region
#        # why is this necessary given that error handling is on?
#        [ ! "${?}" == "0" ] && return ${?}
#
#

function required() {
    local arg
    local error_message=""
    for arg in "${@}"; do
        if [ -z "${!arg+x}" ]; then
            error_message="${error_message} undefined ${arg}"
        elif [ -z "${!arg}" ]; then
            error_message="${error_message} empty ${arg}"
        else
            debugLog "'${arg}' passed"
        fi
    done
    [ -n "${error_message}" ] \
        && error_message="missing required arguments:${error_message}" \
        && echo "$0: ${FUNCNAME[*]:1}: ${error_message}" 1>&2 \
        && debugLog "FAILED" \
        && return 1
    return 0
}



function validate() {
    local usage="validate <variable_ref> [ <allowed_values> ... ]"
    if [ "${#}" == 0 ]; then
        echo "${FUNCNAME[*]:1} : required: missing arguments: ${usage}" 1>&2
        return 1
    elif [ "${#}" == 1 ]; then
        [ -z "${!1+x}" ] && errorMessage "undefined variable '${1}'" && return 1
        [ -z "${!1}" ] && errorMessage "empty variable '${1}'" && return 1
        debugLog "validated '${1}'"
        return 0
    else
        local varname="${1}"
        [ -z "${!varname+x}" ] && errorMessage "undefined variable '${varname}'" && return 1
        shift 1
        for value in "${@}"; do
            [ "${!varname}" == "${value}" ] && debugLog "validated '${varname}'" && return 0
        done
        errorMessage "invalid variable '${varname}' value '${!varname}': valid values: ${*}"
        return 1
    fi
}



function die() {
    echo "$0: ${FUNCNAME[*]:1} : ${*}" 1>&2
    exit 111
}


function try() {
    while [ -z "${1}" ]; do
        shift
    done
    [ "${#}" -lt 1 ] && die "empty try statement"

    ! "$@" && echo "ERROR: $0: ${FUNCNAME[*]:1}: cannot execute: ${*}" 1>&2 && exit 111

    return 0
}
