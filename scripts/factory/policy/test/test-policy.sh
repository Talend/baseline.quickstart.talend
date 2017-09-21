#!/usr/bin/env bash

set -e
set -u

source policy.sh

declare my_policy
policy_public_read my_bucket my_policy

echo "${my_policy}"
