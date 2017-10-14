#!/usr/bin/env bash

set -e
set -u


declare gitHostname="${1:-localhost}"
declare gitPort="${2:-80}"
declare gitPath="${3:-}"
declare searchPattern="${4:-GitLab}"
declare userHome="${4:-/home/ec2-user}"

declare sleepInterval=20

echo "$(date +%Y-%m-%d:%H:%M:%S) --- checking Git status..." 1>&2
until [ "`wget -O - --timeout=5 http://${gitHostname}:${gitPort}/${gitPath} | tee -a ${userHome}/isGitStarted.log | grep '${searchPattern}'`" != "" ]; do
    echo "$(date +%Y-%m-%d:%H:%M:%S) --- sleeping for ${sleepInterval} seconds before checking http://${gitHostname}:${gitPort}/${gitPath}" | tee -a ${userHome}/isGitStarted.log
    sleep "${sleepInterval}"
done
echo "$(date +%Y-%m-%d:%H:%M:%S) --- Git is ready!  http://${gitHostname}:${gitPort}/${gitPath}" | tee -a ${userHome}/isGitStarted.log 1>&2
