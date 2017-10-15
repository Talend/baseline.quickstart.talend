#!/usr/bin/env bash

set -e
set -u


declare gitUrl="${1:-http://localhost/users/sign_in}"
declare searchPattern="${2:-GitLab}"
declare logDir="${3:-/home/ubuntu}"

[ -z "${gitUrl}" ] && echo "parameter gitUrl required: ${usage}" 1>&2 && exit 1

declare usage="./isGitStarted <gitUrl> [ <searchPattern> [ <logDir> ] ]"

declare sleepInterval=20
declare logPath="${logDir}/isGitStarted.log"

echo "gitUrl=${gitUrl}" 1>&2
echo "searchPattern=${searchPattern}" 1>&2
echo "logPath=${logPath}" 1>&2
echo "sleepInterval=${sleepInterval}" 1>&2

echo "$(date +%Y-%m-%d:%H:%M:%S) --- checking Git status..." 1>&2

declare response
response=$(wget -O - --timeout=5 "${gitUrl}" | grep "${searchPattern}")
until [ -n "${response}" ]; do
    echo "$(date +%Y-%m-%d:%H:%M:%S) --- sleeping for ${sleepInterval} seconds before checking ${gitUrl}" >> "${logPath}"
    sleep "${sleepInterval}"
    response=$(wget -O - --timeout=5 "${gitUrl}" | grep "${searchPattern}")
done
echo "$(date +%Y-%m-%d:%H:%M:%S) --- Git is ready! ${gitUrl}" >> "${logPath}"
