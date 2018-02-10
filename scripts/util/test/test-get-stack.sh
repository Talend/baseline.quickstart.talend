#!/usr/bin/env bash

set -e
set -u

source "../util.sh"

function parent_func() {
     child_func a b c
}

function child_func() {
    local my_stack=""

    get_stack my_stack 0

    echo "my_stack=${my_stack}"
}

parent_func a b c
