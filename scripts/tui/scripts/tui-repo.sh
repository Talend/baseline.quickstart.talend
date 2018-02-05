#!/usr/bin/env bash

set -e
set -u

declare talendRepoDir="${1:-}"
declare tuiRepo="${2:-}"
declare talendVersion="${3:-}"

declare usage="./tui-repo.sh <talendRepoDir> <tuiRepo>"

[ -z "${talendRepoDir}" ] && echo "talendRepoDir argument is required: ${usage}" 1>&2 && exit 1
[ -z "${tuiRepo}" ] && echo "tuiRepo argument is required: ${usage}" 1>&2 && exit 1

[ ! -d "${talendRepoDir}" ] && echo "talendRepoDir ${talendRepoDir} does not exist or is not a directory" && exit 1

mkdir -p "${tuiRepo}" "${tuiRepo}/${talendVersion}" "${tuiRepo}/dependencies"

ln -s ${talendRepoDir}/${talendVersion}/* "${tuiRepo}/${talendVersion}"
ln -s ${talendRepoDir}/dependencies/* "${tuiRepo}/dependencies"
