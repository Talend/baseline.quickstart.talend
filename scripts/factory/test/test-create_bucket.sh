#!/usr/bin/env bash

set -e
#set -x

source create-bucket.sh

DEBUG_LOG=true

echo "expect too many arguments"
create_bucket a b c d e || true

echo "expect bucket cannot be empty"
create_bucket "" "us-east-1" || true

echo "expect bucket cannot be blank"
create_bucket "    " "us-east-1" || true

aws s3 rb "s3://eost-test-bucket" 2> /dev/null || true

echo "expect creating bucket"
create_bucket "eost-test-bucket" "us-east-1" || true

echo "expect bucket exists and is writeable"
create_bucket "eost-test-bucket" "us-east-1" || true

test_bucket="test_create_bucket"
aws s3 rb "s3://${test_bucket}" 2> /dev/null || true
create_bucket "${test_bucket}" "us-east-1"
aws s3 rb "s3://${test_bucket}"

