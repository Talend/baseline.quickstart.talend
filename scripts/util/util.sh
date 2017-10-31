#!/usr/bin/env bash

set -u

[ "${UTIL_FLAG:-0}" -gt 0 ] && return 0

export UTIL_FLAG=1


# read here documents into a variable
# then use a here string to access it elsewhere
#
# define myvar <<EOF
# the quick brown fox jumped over the lazy dog
# EOF
#
# grep -q "txt" <<< "$myvar"
#

define(){ IFS=$'\n' read -r -d '' "${1}" || true; }


function warningLog() {
    [ -n "${WARNING_LOG:-}" ] && echo "WARNING: ${*} : ${FUNCNAME[*]:1}" 1>&2
    return 0
}

function infoLog() {
    [ -n "${INFO_LOG:-}" ] && echo "INFO: ${*} : ${FUNCNAME[*]:1}" 1>&2
    return 0
}

function infoVar() {
    [ -n "${INFO_LOG:-}" ] && echo "INFO: ${FUNCNAME[*]:1} : ${1}=${!1}" 1>&2
    return 0
}

function debugLog() {
    [ -n "${DEBUG_LOG:-}" ] && echo "DEBUG: ${FUNCNAME[*]:1} : ${*}" 1>&2
    return 0
}

function debugVar() {
    [ -n "${DEBUG_LOG:-}" ] && echo "DEBUG: ${FUNCNAME[*]:1} : ${1}=${!1}" 1>&2
    return 0
}

function debugStack() {
    if [ -n "${DEBUG_LOG:-}" ] ; then
        local args
        [ "${#}" -gt 0 ] && args=": $*"
        echo "DEBUG: ${FUNCNAME[*]:1}${args}" 1>&2
    fi
}

function errorMessage() { 
    echo "ERROR: $0: ${FUNCNAME[*]:1} : ${*}" 1>&2
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

    ! "$@" && echo "$0: ${FUNCNAME[*]:1}: cannot execute: ${*}" 1>&2 && exit 111

    return 0
}


function assign() {
    local var="${1}"
    local value="${2}"
    required var value
    printf -v "${var}" '%s' "${value}"
}


function required() {

    local arg
    local error_message=""
    for arg in "${@}"; do
        [ -z "${!arg}" ] && error_message="${error_message} ${arg}"
    done
    [ -n "${error_message}" ] \
        && error_message="missing required arguments:${error_message}" \
        && echo "$0: ${FUNCNAME[*]:1}: ${error_message}" 1>&2 \
        && exit 111
    return 0
}
