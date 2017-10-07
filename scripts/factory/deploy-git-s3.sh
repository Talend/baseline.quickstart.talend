#!/usr/bin/env bash

export DEPLOY_GIT_S3_FLAG
[ "${DEPLOY_GIT_S3_FLAG:-0}" -gt 0 ] && return 0

export DEPLOY_GIT_S3_FLAG=1

set -u


deploy_git_s3_script_path=$(readlink -e "${BASH_SOURCE[0]}")
deploy_git_s3_script_dir="${deploy_git_s3_script_path%/*}"

# shellcheck source=../util/util.sh
source "${deploy_git_s3_script_dir}/../util/util.sh"

# shellcheck source=../util/string_util.sh
source "${deploy_git_s3_script_dir}/../util/string_util.sh"

# shellcheck source=../factory/policy.sh
source "${deploy_git_s3_script_dir}/../factory/policy.sh"

# shellcheck source=../factory/create-bucket.sh
source "${deploy_git_s3_script_dir}/../factory/create-bucket.sh"

function git_snapshot_usage() {
    cat 1>&2 <<-EOF

	usage:
	    git_snapshot [ <git_url> [ <git_repo> [ <git_target> ] ] ]

	    git_url: GIT_DEPLOY_HUB
	    git_repo: GIT_DEPLOY_REPO
	    git_target: GIT_DEPLOY_TARGET (master) git tag or branch
	EOF
}

export -f git_snapshot_usage



function git_snapshot() {

    if [ "${1:-}" == "--help" ] || [ "${1:-}" == "-h" ]; then
        git_snapshot_usage
        return 0
    fi

    # git_target is either a tag name or remote branch name
    local git_url="${1:-${git_url:-${GIT_DEPLOY_URL:-}}}"
    local git_repo="${2:-${git_repo:-${GIT_DEPLOY_REPO:-}}}"
    local git_target="${3:-${git_target:-${GIT_DEPLOY_TARGET:-master}}}"

    required git_url git_repo git_target

    debugVar git_url; debugVar git_repo; debugVar git_target

    local deploy_dir="${git_repo}-${git_target}"

    local cloned=false
    [ ! -d "${deploy_dir}" ] && cloned=true && git clone "${git_url}/${git_repo}" "${deploy_dir}"

    try pushd "${deploy_dir}"

    if [ "${cloned}" != "true" ]; then
        # Abort on changes to tracked files
        debugLog "Checking for changes to tracked files"
        git diff --quiet || errorMessage "changes to tracked files detected" || return 1

        # Aborting on finding untracked files
        debugLog "Checking for untracked files"
        git ls-files -o || errorMessage "untracked files detected" || return 1
    fi

    git fetch --all
    git checkout --force "${git_target}"

    # Following two lines only required if you use submodules
    git submodule sync || true
    git submodule update --init --recursive || true

    try popd
}

export -f git_snapshot



function s3_sync_usage() {
    cat 1>&2 <<-EOF

	usage:
	    s3_sync [ <deploy_dir> [ <s3_bucket> [ <s3_path> [ <s3_grant> ] ] ] ]

	    deploy_dir: GIT_DEPLOY_DIR (aws-quickstart-master)
	    s3_bucket: GIT_DEPLOY_S3_BUCKET (talend-quickstart)
	    s3_path: GIT_DEPLOY_S3_PATH (empty string)
	    s3_grant: GIT_DEPLOY_GRANT (empty string)
	EOF
}

export -f s3_sync_usage



function s3_sync() {

    if [ "${1:-}" == "--help" ] || [ "${1:-}" == "-h" ]; then
        s3_sync_usage
        return 0
    fi

    local git_deploy_dir="${1:-${git_deploy_dir:-${GIT_DEPLOY_DIR:-}}}"
    local s3_bucket="${2:-${s3_bucket:-${GIT_DEPLOY_S3_BUCKET:-}}}"
    local s3_path="${3:-${s3_path:-${GIT_DEPLOY_S3_PATH:-}}}"
    local s3_grant="${4:-${s3_grant:-${GIT_DEPLOY_S3_GRANT:-}}}"

    required git_deploy_dir s3_bucket 

    local -a grantcmd=()
    [ -n "${s3_grant}" ] && grantcmd+=( "--grant" "${s3_grant}" )

    debugLog aws s3 sync "${git_deploy_dir}" "s3://${s3_bucket}${s3_path}" --delete --exclude '.git/*' "${grantcmd[@]}"
    aws s3 sync "${git_deploy_dir}" "s3://${s3_bucket}${s3_path}" --delete --exclude '.git/*' "${grantcmd[@]}"
}

export -f s3_sync



function deploy_git_s3_usage() {
    cat 1>&2 <<-EOF

	usage:
	    deploy_git_s3 [ <git_url> [ <git_repo> [ <git_target> [ <s3_bucket> [ <s3_path> [ <s3_grant> ] ] ] ] ] ]

	    git_url: GIT_DEPLOY_HUB (https://github.com/EdwardOst)
	    git_repo: GIT_DEPLOY_REPO (aws-quickstart)
	    git_target: GIT_DEPLOY_TARGET (master) git tag or branch
	    s3_bucket: GIT_DEPLOY_S3_BUCKET (talend-quickstart)
	    s3_path: GIT_DEPLOY_S3_PATH (empty string)
	    s3_grant: GIT_DEPLOY_GRANT (empty string)
	EOF
}

export -f deploy_git_s3_usage

function deploy_git_s3() {

    if [ "${1:-}" == "--help" ] || [ "${1:-}" == "-h" ]; then
        deploy_git_s3_usage
        return 0
    fi

    local git_url="${1:-${git_url:-${GIT_DEPLOY_URL:-}}}"
    local git_repo="${2:-${git_repo:-${GIT_DEPLOY_REPO:-}}}"
    local git_target="${3:-${git_target:-${GIT_DEPLOY_TARGET:-}}}"
    local s3_bucket="${4:-${s3_bucket:-${GIT_DEPLOY_S3_BUCKET:-}}}"
    local s3_path="${5:-${s3_path:-${GIT_DEPLOY_S3_PATH:-}}}"
    local s3_grant="${6:-${s3_grant:-${GIT_DEPLOY_S3_GRANT:-}}}"

    required git_url git_repo git_target s3_bucket

    debugVar git_url; debugVar git_repo; debugVar git_target; debugVar s3_bucket

    create_bucket "${s3_bucket}"

    local deploy_bucket_policy
    policy_public_read deploy_bucket_policy "${s3_bucket}"
    local policy_file="${s3_bucket}.policy"
    echo "${deploy_bucket_policy}" > "${policy_file}"
    attach_policy "${policy_file}" "${s3_bucket}"

    git_snapshot "${git_url}" "${git_repo}" "${git_target}"

    s3_sync "${git_repo}-${git_target}" "${s3_bucket}" "${s3_path}" "${s3_grant}"
}

export -f deploy_git_s3
