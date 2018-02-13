#!/usr/bin/env bash

set -e
set -u

source ../string_util.sh

function mytest() {
    local result=""

    string_repeat result "=" 40
    echo "${result}"
}

mytest
