#!/usr/bin/env bash

set -e
set -u

# #[ "${#}" -lt 1 ] && echo "usage: download-talend-license <bucket_name> [ <target_dir> ]" && exit 1

declare bucket_name="${1:-}"
declare target_dir="${2:-/home/ubuntu/generated/licenses/license}"

echo "bucket_name=${bucket_name}"
echo "target_dir=${target_dir}"

# #[ "${#}" -lt 1 ] && echo "usage: download-talend-license <bucket_name> [ <target_dir> ]" && exit 1

#echo "command: aws --output text s3api get-bucket-location --bucket ${bucket_name}"
#aws --output text s3api get-bucket-location --bucket ${bucket_name}

#declare TalendLicenseBucketRegion=$(aws --output text s3api get-bucket-location --bucket ${bucket_name})
#echo "TalendLicenseBucketRegion=${TalendLicenseBucketRegion}"
#aws s3 --region "${TalendLicenseBucketRegion}" cp s3://${bucket_name}/license ${target_dir}

aws s3 cp s3://${bucket_name}/license ${target_dir}