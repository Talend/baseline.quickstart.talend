#!/usr/bin/env bash

set -e
set -u


declare stack="${1:-}"
declare resourceId="${2:-}"
declare region="${3:-}"
declare maxWait="${4:-900}"
declare sleepInterval="${5:-20}"

declare usage="./isResourceAvailable <stack> <resourceId> [ <maxWait> [ <sleepInterval> ] ]"

[ -z "${stack}" ] && echo "stack parameter is required: ${usage}" 1>&2 && exit 1
[ -z "${resourceId}" ] && echo "resourceId parameter is required: ${usage}" 1>&2 && exit 1
[ -z "${region}" ] && echo "region parameter is required: ${usage}" 1>&2 && exit 1

echo "$(date +%Y-%m-%d:%H:%M:%S) --- checking ${stack}:${resourceId} status..." 1>&2
declare resource_info
resource_info=$( aws cloudformation describe-stack-resource --region ${region} --stack-name "${stack}" --logical-resource-id "${resourceId}" | jq --raw-output ".StackResourceDetail.ResourceStatus" )
SECONDS=0

until [ "${resource_info}" == "CREATE_COMPLETE" ] || [ "${resource_info}" == "UPDATE_COMPLETE" ] || [ ${SECONDS} -gt "${maxWait}" ]; do
    echo "resource_info=${resource_info}" 1>&2
    echo "$(date +%Y-%m-%d:%H:%M:%S) --- ${SECONDS} / ${maxWait} --- sleeping for ${sleepInterval} seconds before checking ${stack}:${resourceId}" 1>&2
    sleep "${sleepInterval}"
    resource_info=$( aws cloudformation describe-stack-resource --region ${region} --stack-name "${stack}" --logical-resource-id "${resourceId}" | jq --raw-output ".StackResourceDetail.ResourceStatus" )
done
echo "resource_info=${resource_info}" 1>&2
[ -n "${resource_info}" ] && echo "$(date +%Y-%m-%d:%H:%M:%S) --- ${stack}:${resourceId} is ready!" 1>&2 && exit 0
[ -z "${resource_info}" ] && echo "$(date +%Y-%m-%d:%H:%M:%S) --- ${stack}:${resourceId} NOT ready!" 1>&2  && exit 1
