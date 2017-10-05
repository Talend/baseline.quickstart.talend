#!/bin/bash

set -e
set -u

function load_git() {

    local source_zip_path="${1:-${SOURCE_ZIP_PATH:-}}"
    local work_dir="${2:-${TALEND_WORK_DIR:-${PWD}/work}}"
    local git_protocol="${3:-${GIT_PROTOCOL:-}}"
    local git_host="${4:-${GIT_HOST:-}}"
    local git_repo_owner="${5:-${GIT_REPO_OWNER:-}}"
    local git_repo="${6:-${GIT_REPO:-}}"
    local git_user="${7:-${GIT_USER:-}}"
    local git_password="${8:-${GIT_PASSWORD:-}}"

    local usage="load_project_to_git <source_zip_path> <work_dir> <git_protocol> <git_host> <git_repo_owner> <git_repo> <git_user> <git_password>"
    [ -z "${source_zip_path}" ] && echo "source_zip_path required: ${usage}" 1>&2 && return 1
    [ ! -f "${source_zip_path}" ] && echo "source_zip_path '${source_zip_path}' does not exist: ${usage}" 1>&2 && return 1
    [ -z "${work_dir}" ] && echo "work_dir required: ${usage}" 1>&2 && return 1
    [ -z "${git_protocol}" ] && echo "git_protocol required: ${usage}" 1>&2 && return 1
    [ -z "${git_repo}" ] && echo "git_repo required: ${usage}" 1>&2 && return 1
    [ -z "${git_user}" ] && echo "git_user required: ${usage}" 1>&2 && return 1
    [ -z "${git_password}" ] && echo "git_password required: ${usage}" 1>&2 && return 1

    local git_url="${git_protocol}://${git_user}:${git_password}@${git_host}/${git_repo_owner}/${git_repo}.git"

    local project_name="${source_zip_path##*/}"
    project_name="${project_name%.*}"

    [ ! -d "${work_dir}" ] && echo "WARNING: '${work_dir}' doest not exist: creating directory" 1>&2 && mkdir -p "${work_dir}"

    cd "${work_dir}"
    git clone "${git_url}" "${project_name}"
    tar -xzvf "${source_zip_path}"
    cd "${project_name}"
    git add .
    git commit -m "initial version"
    git push --all
}

#load_git \
#        oodlejobs.tgz \
#        /home/ec2-user/work \
#        https \
#        github.com \
#        EdwardOst \
#        quickstart-repo \
#        EdwardOst \
#        mypassword
