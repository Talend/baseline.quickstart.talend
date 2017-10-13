#!/usr/bin/env bash

set -e
set -u

tacHostname="${1:-localhost}"
tacPort="${2:-8080}"
tacPath="${3:-tac}"
user="${4:-ec2-user}"

echo "$(date +%Y-%m-%d:%H:%M:%S) --- checking TAC status..." 1>&2
until [ "`wget -O - --timeout=5 http://${tacHostname}:${tacPort}/${tacPath} | tee -a /home/${user}/isTACStarted.log | grep 'noscript'`" != "" ]; do
    echo "$(date +%Y-%m-%d:%H:%M:%S) --- sleeping for 10 seconds before checking http://${tacHostname}:${tacPort}/${tacPath}" | tee -a /home/${user}/isTACStarted.log
    sleep 20
done
echo "$(date +%Y-%m-%d:%H:%M:%S) --- TAC is ready!  http://${tacHostname}:${tacPort}/${tacPath}" | tee -a /home/${user}/isTACStarted.log 1>&2
