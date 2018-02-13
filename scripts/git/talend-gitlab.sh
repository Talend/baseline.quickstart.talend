#!/bin/bash

set -e
set -u

function gitlab_init() {

    local usage="gitlab_init.sh <git_admin_userid> <git_admin_password> <git_admin_email> <git_tac_userid> <git_tac_password> <git_tac_email> <git_repo>"

    local git_admin_userid="${1:-${git_admin_userid:-}}"
    local git_admin_password="${2:-${git_admin_password:-}}"
    local git_admin_email="${3:-${git_admin_email:-}}"
    local git_tac_userid="${4:-${git_tac_userid:-}}"
    local git_tac_password="${5:-${git_tac_password:-}}"
    local git_tac_email="${6:-${git_tac_email:-}}"
    local git_repo="${7:-${git_repo:-}}"

    [ -z "${git_admin_userid}" ] && echo "invalid argument git_admin_userid cannot be empty: usage: ${usage}" && return 1
    [ -z "${git_admin_password}" ] && echo "invalid argument git_admin_password cannot be empty: usage: ${usage}" && return 1
    [ -z "${git_admin_email}" ] && echo "invalid argument git_admin_email cannot be empty: usage: ${usage}" && return 1
    [ -z "${git_tac_userid}" ] && echo "invalid argument git_tac_userid cannot be empty: usage: ${usage}" && return 1
    [ -z "${git_tac_password}" ] && echo "invalid argument git_tac_password cannot be empty: usage: ${usage}" && return 1
    [ -z "${git_tac_email}" ] && echo "invalid argument git_tac_email cannot be empty: usage: ${usage}" && return 1
    [ -z "${git_repo}" ] && echo "invalid argument git_repo cannot be empty: usage: ${usage}" && return 1

    #Install the packages.  The wait is to prevent a stall after reconfigure

    # gitlab-ctl reconfigure
    # sleep 1m
    # apt-get install -y ruby
    # apt-get install -y jq
    # gem install gitlab

    # Configure git accounts with usernames/passwords

    # need to confirm that the gitlab-rails runner will accept unquoted arguments.  the outer quote needs to use double quotes in order
    # for bash parameter expansion to work
    echo ""
    echo "creating git admin user: '${git_admin_userid}', email: '${git_admin_email}'"
    gitlab-rails runner "User.create!(username: \"${git_admin_userid}\", email: \"${git_admin_email}\", password: \"${git_admin_password}\", password_confirmation: \"${git_admin_password}\", name: \"${git_admin_userid}\", admin: \"true\")"

    echo "creating git tac user: '${git_tac_userid}', email: '${git_tac_email}'"
    gitlab-rails runner "User.create!(username: \"${git_tac_userid}\", email: \"${git_tac_email}\", password: \"${git_tac_password}\", password_confirmation: \"${git_tac_password}\", name: \"${git_tac_userid}\")"

    # This next section puts the ip in as the first variable and the access token as the second

    echo "getting ip"
    local ipvar
    # this probably needs to be private ip since server cannot access its own external ip, just its private ip
    ipvar=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
    echo "ip=${ipvar}"

    echo "getting private token"
    echo "curl http://${ipvar}/api/v3/session --data login=${git_admin_userid}&password=${git_admin_password}"
    local xvar
    xvar=$(curl "http://${ipvar}/api/v3/session" --data "login=${git_admin_userid}&password=${git_admin_password}" | jq --raw-output .private_token)
    echo "xvar=${xvar}"

    # Create the project, clone it to local file, populate it with demo, and push it

    echo "creating project ${git_repo}"
    curl --header "PRIVATE-TOKEN: ${xvar}" -X POST --data-urlencode 'visibility_level=10' "http://${ipvar}/api/v3/projects?name=${git_repo}"

}
