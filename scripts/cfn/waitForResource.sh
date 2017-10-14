#!/usr/bin/env bash

set -e
set -u


declare stack="${1:-}"
declare resourceId="${2:-}"
declare sleepInterval="${3:-20}"

declare usage="./isResourceAvailable <stack> <resourceId> [ <sleepInterval> ]"

[ -z "${stack}" ] && echo "stack parameter is required: ${usage}" 1>&2 && exit 1
[ -z "${resourceId}" ] && echo "resourceId parameter is required: ${usage}" 1>&2 && exit 1

echo "$(date +%Y-%m-%d:%H:%M:%S) --- checking ${stack}:${resourceId} status..." 1>&2
declare resource_info
resource_info=$( aws cloudformation describe-stack-resource --stack-name "${stack}" --logical-resource-id "${resourceId}" | jq --raw-output ".StackResourceDetail.ResourceStatus" )

until [ "${resource_info}" == "CREATE_COMPLETE" ] || [ "${resource_info}" == "UPDATE_COMPLETE" ]; do
    echo "resource_info=${resource_info}" 1>&2
    echo "$(date +%Y-%m-%d:%H:%M:%S) --- sleeping for ${sleepInterval} seconds before checking ${stack}:${resourceId}" 1>&2
    sleep "${sleepInterval}"
    resource_info=$( aws cloudformation describe-stack-resource --stack-name "${stack}" --logical-resource-id "${resourceId}" | jq --raw-output ".StackResourceDetail.ResourceStatus" )
done
echo "resource_info=${resource_info}" 1>&2
echo "$(date +%Y-%m-%d:%H:%M:%S) --- ${stack}:${resourceId} is ready!" 1>&2
