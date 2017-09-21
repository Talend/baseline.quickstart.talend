#!/usr/bin/env bash

set -e
#set -x

source create-license-bucket.sh

DEBUG_LOG=true

echo "expect too many arguments"
create_license_bucket a b c d e || true

echo "expect license owner cannot be empty"
create_license_bucket "" || true

echo "expect license owner cannot be blank"
create_license_bucket "    " || true

echo "expect bucket cannot be empty"
create_license_bucket "eost" "" || true

echo "expect bucket cannot be blank"
create_license_bucket "eost" "    " || true

aws s3 rb s3://eost-license || true

echo "expect creating bucket"
create_license_bucket eost eost-license || true

echo "expect bucket exists and is writeable"
create_license_bucket eost eost-license || true

test_bucket="test_create_license_bucket"
aws s3 rb "s3://${test_bucket}" 2> /dev/null || true
create_license_bucket "eost" "${test_bucket}"
aws s3 rb "s3://${test_bucket}"

