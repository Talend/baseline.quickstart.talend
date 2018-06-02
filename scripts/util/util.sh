#!/usr/bin/env bash

set -e
set -u

[ "${UTIL_FLAG:-0}" -gt 0 ] && return 0

export UTIL_FLAG=1

util_script_path=$(readlink -e "${BASH_SOURCE[0]}")
util_script_dir="${util_script_path%/*}"

# shellcheck source=./string_util.sh
source "${util_script_dir}/string_util.sh"


function get_stack() {
    local _stack="${1:-}"
    local stack_offset="${2:-1}"

    local stack_out=""
    local stack_index="${stack_offset}"
    for current_source in "${BASH_SOURCE[@]:${stack_offset}}"; do
        local source_index=$((stack_index - 1))
        stack_out+="${FUNCNAME[${source_index}]}[${current_source##*/}#${BASH_LINENO[${source_index}]}] "
        stack_index=$((stack_index + 1))
    done

    [ -z "${_stack}" ] && echo "ERROR : ${0} : '_stack' argument required : ${stack_out}" 1>&2 && return 1
    [ -z "${stack_offset}" ] && echo "ERROR : ${0} : 'stack_offset' argument required : ${stack_out}" 1>&2 && return 1
    [ -z "${!_stack+x}" ] && echo "ERROR : ${0} : reference variable _stack['${_stack}'] not defined prior to use : ${stack_out}" 1>&2 && return 1

    printf -v "${_stack}" '%s' "${stack_out}"
    return 0
}


function call_stack() {

    local n=0
    while caller $((n++)); do
        :
    done
}


function assign() {
    local _var="${1:-}"
    local value="${2}"
    local stack=""
    get_stack stack 2

    [ -z "${_var}" ] && echo "ERROR : ${0} : '_var' argument required : ${stack}" 1>&2 && return 1
    [ -z "${!_var+x}" ] && echo "ERROR: ${0} : reference variable _var['${_var}'] not defined prior to use : ${stack}" 1>&2 && return 1
    printf -v "${_var}" '%s' "${value}"
}


define(){
    IFS=$'\n' read -r -d '' "${1}" || true;
}


function indent() {
    local _indent="${1}"

    local indent_out=""
    local depth=${#FUNCNAME[@]}
    local depth=$((depth - 2))
    local depth=$((depth * 2))
    string_repeat indent_out " " "${depth}"
    printf -v "${_indent}" "%s" "${indent_out}"
}


function warningLog() {
    local stack=""
    get_stack stack 2

    local spaces=""
    indent spaces
    [ -n "${WARNING_LOG:-}" ] && echo "${spaces}WARNING: ${*} : ${stack}" 1>&2
    return 0
}


function infoStack() {
    local stack=""
    get_stack stack 2

    local spaces=""
    indent spaces
    [ -n "${INFO_LOG:-}" ] && echo "${spaces}INFO: ${*} : ${stack}" 1>&2
    return 0
}


function infoLog() {

    local spaces=""
    indent spaces
    [ -n "${INFO_LOG:-}" ] && echo "${spaces}INFO: ${*}" 1>&2
    return 0
}


function infoVar() {
    local _varname="${1:-}"
    local show_stack="${2:-}"

    local stack=""

    if [ -z "${_varname}" ]; then
        get_stack stack 2
        echo "ERROR: infoVar missing varname argument: ${stack}"
        return 0
    fi

    [ "${show_stack}" == "true" ] && get_stack stack 2

    local spaces=""
    indent spaces
    [ -n "${INFO_LOG:-}" ] && [ -z "${!_varname+x}" ] && echo "${spaces}INFO: undefined variable '${_varname}' : ${stack}" && return 0
    [ -n "${INFO_LOG:-}" ] && echo "${spaces}INFO: VAR: ${FUNCNAME[1]}: ${_varname}=${!_varname} : ${stack}" 1>&2 && return 0
    return 0
}


function debugStack() {
    local stack=""
    get_stack stack 2

    local spaces=""
    indent spaces
    [ -n "${DEBUG_LOG:-}" ] && echo "${spaces}DEBUG: ${*} : ${stack}" 1>&2
    return 0
}


function debugLog() {

    local spaces=""
    indent spaces
    [ -n "${DEBUG_LOG:-}" ] && echo "${spaces}DEBUG: ${*}" 1>&2
    return 0
}


function debugVar() {
    local _varname="${1:-}"
    local show_stack="${2:-}"

    local stack=""

    if [ -z "${_varname}" ]; then
        get_stack stack 2
        echo "ERROR: debugVar missing varname argument: ${stack}"
        return 0
    fi

    [ "${show_stack}" == "true" ] && get_stack stack 2

    local spaces=""
    indent spaces
    [ -n "${DEBUG_LOG:-}" ] && [ -z "${!_varname+x}" ] && echo "${spaces}DEBUG: undefined variable '${_varname}' : ${stack}" && return 0
    [ -n "${DEBUG_LOG:-}" ] && echo "${spaces}DEBUG: VAR: ${FUNCNAME[1]}: ${_varname}=${!_varname} : ${stack}" 1>&2 && return 0
    return 0
}


function errorMessage() {
    local message="${1:-}"
    local stack_offset="${2:-2}"

    local stack=""
    get_stack stack "${stack_offset}"

    local spaces=""
    indent spaces
    echo "${spaces}ERROR: ${message} : ${stack}" 1>&2
}


function defined() {
    local arg
    local error_message=""

    for arg in "${@}"; do
        if [ -z "${!arg+x}" ]; then
            error_message="${error_message} : undefined ${arg}"
        else
            debugLog "'${arg}' passed"
        fi
    done
    [ -n "${error_message}" ] \
        && errorMessage "undefined variables${error_message}" \
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
            error_message="${error_message} : undefined ${arg}"
        elif [ -z "${!arg}" ]; then
            error_message="${error_message} : empty ${arg}"
        else
            debugLog "'${arg}' passed"
        fi
    done
    [ -n "${error_message}" ] \
        && errorMessage "missing required arguments${error_message}" \
        && return 1
    return 0
}



function validate() {
    local usage="validate <variable_ref> [ <allowed_values> ... ]"
    if [ "${#}" == 0 ]; then
        errorMessage "missing arguments : ${usage}" 1>&2
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
    errorMessage "${1}" 2 1>&2
    exit 111
}


function try() {
    while [ -z "${1}" ]; do
        shift
    done
    [ "${#}" -lt 1 ] && die "empty try statement"

    ! "$@" && errorMessage "cannot execute: ${*}" 2 1>&2 && call_stack && exit 111

    return 0
}

# usage
#
# umask_scope <umask_value> <command> <...>

function umask_scope() {

    local umask_save
    umask_save=$(umask)

    umask "${1}"
    shift 1

    "${@}"

    umask "${umask_save}"
}

export -f get_stack
export -f assign
export -f indent
export -f warningLog
export -f infoStack
export -f infoLog
export -f infoVar
export -f debugStack
export -f debugLog
export -f debugVar
export -f errorMessage
export -f defined
export -f required
export -f validate
export -f die
export -f try
export -f umask_scope
