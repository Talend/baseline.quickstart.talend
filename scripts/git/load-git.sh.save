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

    echo "source_zip_path=${source_zip_path}" 1>&2
    echo "work_dir=${work_dir}" 1>&2
    echo "git_protocol=${git_protocol}" 1>&2
    echo "git_host=${git_host}" 1>&2
    echo "git_repo_owner=${git_repo_owner}" 1>&2
    echo "git_repo=${git_repo}" 1>&2
    echo "git_user=${git_user}" 1>&2
    echo "git_password=${git_password}" 1>&2

    local git_url="${git_protocol}://${git_user}:${git_password}@${git_host}/${git_repo_owner}/${git_repo}.git"

    local project_name="${source_zip_path##*/}"
    project_name="${project_name%.*}"

    [ ! -d "${work_dir}" ] && echo "WARNING: '${work_dir}' doest not exist: creating directory" 1>&2 && mkdir -p "${work_dir}"

    echo "director is ${work_dir}" 1>&2
    cd "${work_dir}"

    echo "cloning ${git_url} to ${project_name}" 1>&2
    git clone "${git_url}" "${project_name}"

    tar -xzf "${source_zip_path}"
    cd "${project_name}"
    git add .
    git commit -m "initial version" && true
    [ "${?}" -ne 0 ] && echo "repository already up to date, no commit or push" 1>&2 && return 0
    git push --all

    echo "pushed" 1>&2
}

#load_git \
#        /opt/repo/demo_jobs/oodlejobs.tgz \
#        /home/ec2-user/work \
#        http \
#        ec2-34-230-23-78.compute-1.amazonaws.com \
#        tadmin \
#        oodlejobs \
#        tadmin \
#        tadm1nPassw0rd
