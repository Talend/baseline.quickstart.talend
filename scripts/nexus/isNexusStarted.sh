#!/usr/bin/env bash

set -e
set -u


declare nexusHostname="${1:-localhost}"
declare nexusPort="${2:-8081}"
declare nexusPath="${3:-nexus}"
declare userHome="${4:-/home/ec2-user}"

echo "$(date +%Y-%m-%d:%H:%M:%S) --- checking Nexus status..." 1>&2
until [ "`wget -O - --timeout=10 http://${nexusHostname}:${nexusPort}/${nexusPath} | tee -a ${userHome}/isNexusStarted.log | grep 'Type in the name of a project'`" != "" ]; do
    echo "$(date +%Y-%m-%d:%H:%M:%S) --- sleeping for 10 seconds before checking http://${nexusHostname}:${nexusPort}/${nexusPath}" | tee -a ${userHome}/isNexusStarted.log
    sleep 10
done
echo "$(date +%Y-%m-%d:%H:%M:%S) --- Nexus is ready!  http://${nexusHostname}:${nexusPort}/${nexusPath}" | tee -a ${userHome}/isNexusStarted.log 1>&2
