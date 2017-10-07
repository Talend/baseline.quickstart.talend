#!/usr/bin/env bash

set -u

[ "${BUILD_FLAG:-0}" -gt 0 ] && return 0

export BUILD_FLAG=1

build_script_path=$(readlink -e "${BASH_SOURCE[0]}")
build_script_dir="${build_script_path%/*}"

# shellcheck source=../util/util.sh
source "${build_script_dir}/../util/util.sh"
# shellcheck source=../util/string_util.sh
source "${build_script_dir}/../util/string_util.sh"
# shellcheck source=../s3fs/s3fs-util.sh
source "${build_script_dir}/../s3fs/s3fs-util.sh"
# shellcheck source=./policy.sh
source "${build_script_dir}/policy.sh"
# shellcheck source=./create-bucket.sh
source "${build_script_dir}/create-bucket.sh"
# shellcheck source=./deploy-git-s3.sh
source "${build_script_dir}/deploy-git-s3.sh"


# TODO:

# option on step 2
# Load License


function talend_factory_setup() {

    sudo "${build_script_dir}/../bootstrap/update_hosts.sh"
    sudo "${build_script_dir}/../java/jre-installer.sh"
}


function download() {
    local url="${1:-}"
    local file_path_ref="${2:-}"

    required url file_path_ref

    # [ -z "${url}" ] && errorMessage "url required" && return 1
    # [ -z "${file_path_ref}" ] && errorMessage "file_path_ref required" && return 1

    local file_name="${url##*/}"
    local file_path
    file_path="$(pwd)/${file_name}"
    assign "${file_path_ref}" "${file_path}"

    string_begins_with "${url}" "s3:" && aws s3 cp "${url}" . && return 0

    string_begins_with "${url}" "http" && wget "${url}" && return 0

    [ -f "${url}" ] && return 0
}

export -f download


function load_repo() {
    local license_file_path="${1:-}"

    local talend_userid="${2:-${talend_userid:-${TALEND_FACTORY_TALEND_USERID:-}}}"
    local talend_password="${3:-${talend_password:-${TALEND_FACTORY_TALEND_PASSWORD:-}}}"
    local tui_path="${4:-${tui_path:-${TALEND_FACTORY_TUI_PATH:-}}}"
    local tui_profile="${5:-${tui_profile:-${TALEND_FACTORY_TUI_PROFILE:-}}}"
    local repo_bucket="${6:-${repo_bucket:-${TALEND_FACTORY_REPO_BUCKET:-}}}"
    local repo_path="${7:-${repo_path:-${TALEND_FACTORY_REPO_PATH:-}}}"
    local repo_mount_dir="${8:-${repo_mount_dir:-${TALEND_FACTORY_REPO_MOUNT_DIR:-}}}"
    local java_target_dir="${9:-${java_target_dir:-${TALEND_FACTORY_JAVA_TARGET_DIR:-}}}"
    local java_filename="${10:-${java_filename:-}}"
    local s3fs_target_dir="${11:-${s3fs_target_dir:-${TALEND_FACTORY_S3FS_TARGET_DIR:-}}}"
    local s3fs_filename="${12:-${s3fs_filename:-}}"
    local default_user="${13:-${default_user:-${TALEND_FACTORY_DEFAULT_USER:-}}}"

    try required license_file_path talend_userid talend_password tui_path tui_profile repo_bucket repo_path repo_mount_dir java_target_dir java_filename

    debugVar license_file_path; debugVar talend_userid; debugVar talend_password; debugVar tui_path; debugVar tui_profile; debugVar repo_bucket; debugVar repo_path; debugVar repo_mount_dir; debugVar java_target_dir; debugVar java_filename; debugVar s3fs_target_dir; debugVar s3fs_filename

    string_contains "${repo_bucket}" "." && errorMessage "invalid repo bucket name '${repo_bucket}', repo bucket name cannot contain periods" && return 1

    infoLog "Creating repository bucket"
    try create_bucket "${repo_bucket}"

    infoLog "Unpack tui and copy tui config"
    local tui_file_path
    try download "${tui_path}" tui_file_path
    # source filename
    local tui_file_name="${tui_file_path##*/}"
    # target directory is the root of the filename
    local tui_dir="${tui_file_name%.*}"
    tar xvpf "${tui_file_path}"
    debugLog "cp -rf ${build_script_dir}/../tui/conf/* ${tui_dir}/conf"
    cp -rf "${build_script_dir}"/../tui/conf/* "${tui_dir}/conf"

    infoLog "Set tui license"
    cp "${license_file_path}" "${tui_dir}/licenses/6.3.1"

    infoLog "Set tui credentials"
    cat > "${tui_dir}/licenses/6.3.1/download_credentials.properties" <<EOF
TALEND_DOWNLOAD_USER=${talend_userid}
TALEND_DOWNLOAD_PASSWORD=${talend_password}
EOF

    infoLog "Build and mount s3fs"

    try s3fs_build
    try s3fs_config
    try s3fs_mount "${repo_bucket}" "${repo_path}" "${repo_mount_dir}" "${repo_mount_dir}" "037" "none" "${default_user}"

    infoLog "Load talend binaries to repo mount using tui"
    "${tui_dir}/install" -q -d "${tui_profile}"

    infoLog "Load tui binary to repo mount"
    local tui_target_dir="${repo_mount_dir}/tui"
    mkdir -p "${tui_target_dir}"
    cp "${tui_file_path}" "${tui_target_dir}"

    infoLog "Load jre to repo mount"
    cp "${java_target_dir}/${java_filename}" "${repo_mount_dir}/dependencies"

    infoLog "Load s3fs to repo mount"
    mkdir -p "${repo_mount_dir}/s3fs"
    cp "${s3fs_target_dir}/${s3fs_filename}" "${repo_mount_dir}/s3fs"

    infoLog "Set owner and permissions for s3fs"
    try s3fs_dir_attrib "${default_user}" "${repo_mount_dir}"
}

export -f load_repo


function load_license() {
    local license_file_path_ref="${1:-}"
    local license_path="${2:-${license_path:-${TALEND_FACTORY_LICENSE_PATH:-}}}"
    local license_bucket="${3:-${license_bucket:-${TALEND_FACTORY_LICENSE_BUCKET:-}}}"

    required license_file_path_ref license_path license_bucket

    # [ -z "${license_file_path_ref}" ] && errorMessage "licence_file_path_ref required" && return 1
    # [ -z "${license_path}" ] && errorMessage "license path required" && return 1
    # [ -z "${license_bucket}" ] && errorMessage "licence_bucket required" && return 1
    [ ! -f "${license_path}" ] && errorMessage "invalid argument: license_path '${license_path}' does not exist" && return 1

    try create_bucket

    debugLog "download ${license_path} ${license_file_path_ref}"
    try download "${license_path}" "${license_file_path_ref}"

    debugLog "aws s3 cp ${!license_file_path_ref} s3://${license_bucket}"
    aws s3 cp "${!license_file_path_ref}" "s3://${license_bucket}"
}

export -f load_license



function build() {
    local license_env="${1:-${license_env:-${TALEND_FACTORY_LICENSE_ENV:-}}}"
    local baseline_env="${2:-${baseline_env:-${TALEND_FACTORY_BASELINE_ENV:-}}}"
    local quickstart_env="${3:-${quickstart_env:-${TALEND_FACTORY_QUICKSTART_ENV:-}}}"
    local repo_env="${4:-${repo_env:-${TALEND_FACTORY_REPO_ENV:-}}}"
    local java_env="${5:-${java_env:-${TALEND_FACTORY_JAVA_ENV:-}}}"
    local default_user="${6:-${default_user:-${TALEND_FACTORY_DEFAULT_USER:-}}}"

    required license_env baseline_env quickstart_env repo_env

    # [ -z "${license_env}" ] && errorMessage "licence_env required" && return 1
    # [ -z "${baseline_env}" ] && errorMessage "baseline_env required" && return 1
    # [ -z "${quickstart_env}" ] && errorMessage "quickstart_env required" && return 1
    # [ -z "${repo_env}" ] && errorMessage "repo_env required" && return 1

    debugVar license_env; debugVar baseline_env; debugVar quickstart_env; debugVar repo_env; debugVar java_env

    infoLog "Upload license from local file system to aws"
    local license_file_path
    try "${license_env}" load_license license_file_path

    infoLog "Attach license policy"
    local license_policy
    try "${license_env}" policy_public_read license_policy
    echo "${license_policy}" > "license.policy"
    try "${license_env}" attach_policy "license.policy"

    infoLog "Upload baseline git repo to baseline bucket"
    try "${baseline_env}" create_bucket
    try "${baseline_env}" deploy_git_s3

    infoLog "Attach baseline policy"
    local baseline_policy
    try "${baseline_env}" policy_public_read baseline_policy
    echo "${baseline_policy}" > "baseline.policy"
    try "${baseline_env}" attach_policy "baseline.policy"

    infoLog "Upload quickstart git repo to quickstart bucket"
    try "${quickstart_env}" create_bucket
    try "${quickstart_env}" deploy_git_s3

    infoLog "Attach quickstart policy"
    local quickstart_policy
    try "${quickstart_env}" policy_public_read quickstart_policy
    echo "${quickstart_policy}" > "quickstart.policy"
    try "${quickstart_env}" attach_policy "quickstart.policy"

    infoLog "Download s3fs binary"
    local s3fs_file_path
    local s3fs_url="${s3fs_path:-https://github.com/s3fs-fuse/s3fs-fuse/archive/v1.82.tar.gz}"
    try download "${s3fs_url}" s3fs_file_path
    local s3fs_filename="${s3fs_file_path##*/}"
    local s3fs_target_dir="${s3fs_file_path%/*}"
    debugVar s3fs_url; debugVar s3fs_target_dir; debugVar s3fs_filename

    infoLog "Create repo-bucket, mount with s3fs, and copy binaries using tui"
    debugLog "load_repo repo_env ${license_file_path}"
    try "${repo_env}" "${java_env}" load_repo "${license_file_path}"

    infoLog "Attach repo policy"
    local repo_policy
    try "${repo_env}" policy_public_read repo_policy
    echo "${repo_policy}" > "repo.policy"
    try "${repo_env}" attach_policy "repo.policy"

    infoLog "Finished -- SUCCESS"
}

export -f build
