#!/usr/bin/env bash

set -e
set -u

source "../util.sh"

WARNING_LOG=true


function parent_func() {
    warningLog "in parent function"

     child_func a b c
}


function child_func() {
    local my_stack=""

    warningLog "in child function"
}

warningLog "shell level"
parent_func a b c
