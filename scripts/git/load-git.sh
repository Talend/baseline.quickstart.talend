#!/bin/bash

set -e
set -u

function load_git() {

    local source_zip_path="${1:-${SOURCE_ZIP_PATH:-}}"
    local target_git_path="${2:-${TARGET_GIT_PATH:-${PWD}/work_repo}}"
    local git_protocol="${3:-${GIT_PROTOCOL:-}}"
    local git_host="${4:-${GIT_HOST:-}}"
    local git_repo_owner="${5:-${GIT_REPO_OWNER:-}}"
    local git_repo="${6:-${GIT_REPO:-}}"
    local git_user="${7:-${GIT_USER:-}}"
    local git_password="${8:-${GIT_PASSWORD:-}}"

    local usage="load_project_to_git <source_zip_path> <target_git_path> <git_protocol> <git_host> <git_repo_owner> <git_repo> <git_user> <git_password>"
    [ -z "${source_zip_path}" ] && echo "source_zip_path required: ${usage}" 1>&2 && return 1
    [ ! -f "${source_zip_path}" ] && echo "source_zip_path '${source_zip_path}' does not exist: ${usage}" 1>&2 && return 1
    [ -z "${target_git_path}" ] && echo "target_git_path required: ${usage}" 1>&2 && return 1
    [ -z "${git_protocol}" ] && echo "git_protocol required: ${usage}" 1>&2 && return 1
    [ -z "${git_repo}" ] && echo "git_repo required: ${usage}" 1>&2 && return 1
    [ -z "${git_user}" ] && echo "git_user required: ${usage}" 1>&2 && return 1
    [ -z "${git_password}" ] && echo "git_password required: ${usage}" 1>&2 && return 1

    local git_url="${git_protocol}://${git_user}:${git_password}@${git_host}/${git_repo_owner}/${git_repo}.git"

    local project_name="${source_zip_path##*/}"
    project_name="${project_name%.*}"

    git clone "${git_url}" "${target_git_path}"
    tar --directory "${target_git_path}" -xzvf "${source_zip_path}"
    cd "${target_git_path}/${project_name}"
    git add .
    git commit -m "initial version"
    git push --all
}

#load_git \
#        DYNAMIC_METADATA.tgz \
#        ./work_repo \
#        https \
#        github.com \
#        EdwardOst \
#        quickstart-repo \
#        EdwardOst \
#        mypassword
