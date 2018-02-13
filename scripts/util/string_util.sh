#!/usr/bin/env bash

set -u

[ "${STRING_UTIL_FLAG:-0}" -gt 0 ] && return 0

export STRING_UTIL_FLAG=1



function trim() {
    [ "${#}" -ne 1 ] && echo "ERROR: trim: invalid number of arguments '${#}'" 1>&2 return 1

    local var_name="${1}"
    local var_value="${!var_name}"

    # remove leading whitespace characters
    var_value="${var_value#${var_value%%[![:space:]]*}}"
    # remove trailing whitespace characters
    var_value="${var_value%${var_value##*[![:space:]]}}"
#    eval "${var_name}=\"${var_value}\""
    printf -v "${var_name}" '%s' "${var_value}"
}


function lowercase() {
    [ "${#}" -ne 1 ] && echo "ERROR: lowercase: invalid number of arguments '${#}'" 1>&2 return 1

    local var_name="${1}"
    local var_value="${!var_name}"

    var_value="${var_value,,}"
#    eval "${var_name}=\"${var_value}\""
   printf -v "${var_name}" '%s' "${var_value}"
}


function string_contains() {
    local astring="${1}"
    local substring="${2}"

    local result="${astring##*${substring}*}"
#    [ -z "${result}" ] && [ -n "${astring}" -o -z "${substring}" ] && return 0 || return 1
    [ -n "${astring}" ] || [ -z "${substring}" ] && [ -z "${result}" ] && return 0 || return 1
}


function string_begins_with() {

    local astring="${1}"
    local substring="${2}"

    [ "${astring:0:${#substring}}" == "${substring}" ] && return 0 || return 1
}


#function string_repeat() {
#
#    local _string="${1}"
#    local char="${2}"
#    local n="${3}"
#
#    local temp_str=""
#    printf -v temp_str "%${n}s"
#    printf -v "${_string}" "%s" "${temp_str// /${char}}"
#}


function string_repeat() {

    local _string="${1}"
    local char="${2}"
    local n="${3}"

#    [ -z "${!string_repeat_dictionary+x}" ] && 
    declare -A string_repeat_dictionary
    if [ ! "${string_repeat_dictionary[${char}]+isset}" ]; then
        printf -v temp_str "${char}%.0s" {1..100}
        string_repeat_dictionary[${char}]="${temp_str}"
    fi

    printf -v "${_string}" "%s" "${temp_str:1:${n}}"
}
