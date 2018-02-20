#!/bin/bash

set -e
set -u

function load_git() {

    local source_zip_path="${1:-}"
    local work_dir="${2:-}"
    local git_url="${3:-}"
    local git_lab_host="${4:-}"
    local git_admin_user="${5:-}"
    local git_admin_password="${6:-}"

    local usage="load_project_to_git <source_zip_path> <work_dir> <git_url> <git_lab_host> <git_admin_user> <git_admin_password>"

    [ -z "${source_zip_path}" ] && echo "source_zip_path required: ${usage}" 1>&2 && return 1
    [ ! -f "${source_zip_path}" ] && echo "source_zip_path '${source_zip_path}' does not exist: ${usage}" 1>&2 && return 1
    [ -z "${work_dir}" ] && echo "work_dir required: ${usage}" 1>&2 && return 1
    [ -z "${git_admin_user}" ] && echo "git_admin_user required: ${usage}" 1>&2 && return 1
    [ -z "${git_admin_password}" ] && echo "git_admin_password required: ${usage}" 1>&2 && return 1

    # either git_url xor git_lab_host must be provided.
    [ -z "${git_url}" ] && [ -z "${git_lab_host}" ] && echo "either git_url or git_lab_host must be non-empty: ${usage}" 1>&2 && return 1


    echo "source_zip_path=${source_zip_path}" 1>&2
    echo "work_dir=${work_dir}" 1>&2
    echo "git_url=${get_url}" 1>&2
    echo "git_lab_host=${get_host}" 1>&2
    echo "git_admin_user=${git_admin_user}" 1>&2
    echo "git_admin_password=${git_admin_password}" 1>&2

    # if git_url is blank then use default configuration
    if [ -z "${git_url}" ]; then
        # this needs to be public dns
        local git_repo_owner="tadmin"
        local git_repo="oodlejobs"
        git_url="http://${git_admin_user}:${git_admin_password}@${git_lab_host}/${git_repo_owner}/${git_repo}.git"
    fi

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
