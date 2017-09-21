#!/usr/bin/env bash

set -e
#set -x

source create-repo-bucket.sh

DEBUG_LOG=true

echo "expect too many arguments"
create_repo_bucket a b c d e || true

echo "expect bucket cannot be empty"
create_repo_bucket "" || true

echo "expect bucket cannot be blank"
create_repo_bucket "    " || true

aws s3 rb "s3://eost-repo" 2> /dev/null || true

echo "expect creating bucket"
create_repo_bucket eost-repo || true

echo "expect bucket exists and is writeable"
create_repo_bucket eost-repo || true

test_bucket="test_create_repo_bucket"
aws s3 rb "s3://${test_bucket}" 2> /dev/null || true
create_repo_bucket "${test_bucket}"
aws s3 rb "s3://${test_bucket}"

