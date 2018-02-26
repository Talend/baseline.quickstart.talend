#!/bin/sh

set -e
set -x

script_path=$(readlink -e "${BASH_SOURCE[0]}")
script_dir="${script_path%/*}"

declare talend_version="${1:-}"
declare tac_password="${2:-}"
declare user_type="${3:-}"
declare project_users_file="${4:-${script_dir}/project-users.data}"

#
# IMPORTANT
# if the user_type parameter is passed it will override not only the user type for the tadmin user
# but for all users that are created from the project_users.data file.
#

declare usage="create-tac-project-users.sh <talend_version> <tac_password> [ <user_type> [ <project_users_file> ] ]"

[ -z "${tac_password}" ] && echo "tac_password required: usage: ${usage}" && exit 1

[ -z "${project_users_file}" ] && echo "project users data file argument required: usage: ${usage}" && exit 1

[ ! -f "${project_users_file}" ] && echo "project users data file argument '${projects_users_file}' does not exist" && exit 1

declare tac_url="http://localhost:8080/tac"
declare metaservlet_path="/opt/talend/${talend_version}/tac/webapps/tac/WEB-INF/classes/MetaServletCaller.sh"
chmod 750 "${metaservlet_path}"


# specify default roles for tadmin
if [ "${talend_version}" == "6.3.1" ]; then
    declare default_account_user="admin@company.com"
    declare default_account_password="admin"
    declare default_account_roles='"Administrator","Operation Manager","Designer"'
else
    declare default_account_user="security@company.com"
    declare default_account_password="admin"
    declare default_account_roles='"Administrator","Operation Manager","Designer","Security Administrator"'
fi

# create tadmin with password from environment

declare USER_FNAME="Talend"
declare USER_LNAME="Administrator"
declare USER_LOGIN="tadmin@talend.com"
declare USER_PASSWD="${tac_password}"
declare USER_TYPE="${user_type:-DI}"
#JSON={"actionName":"createUser","authPass":"admin","authUser":"admin@company.com","userFirstName":"$USER_FNAME","userLastName":"$USER_LNAME","userLogin":"$USER_LOGIN","userPassword":"$USER_PASSWD","userRole":["Administrator","Operation Manager","Designer"],"userType":"$USER_TYPE"}
JSON={"actionName":"createUser","authPass":"${default_account_password}","authUser":"${default_account_user}","userFirstName":"$USER_FNAME","userLastName":"$USER_LNAME","userLogin":"$USER_LOGIN","userPassword":"$USER_PASSWD","userRole":["${default_account_roles}"],"userType":"$USER_TYPE"}
"${metaservlet_path}" --tac-url "${tac_url}" --json-params="${JSON}"
echo "tadmin added: result $?"


# process project_users_file

while read line; do
    REQ_TYPE=`echo $line | awk -F "," '{print $1}'`
    if [ "${REQ_TYPE}" == "USER" ]
    then
        USER_FNAME=`echo $line | awk -F "," '{print $2}'`
        USER_LNAME=`echo $line | awk -F "," '{print $3}'`
        USER_LOGIN=`echo $line | awk -F "," '{print $4}'`
        USER_PASSWD=`echo $line | awk -F "," '{print $5}'`
        USER_TYPE=`echo $line | awk -F "," '{print $6}'`
# if the user_type script parameter is set, it overrides anything read from project_users.data config file
        USER_TYPE="${user_type:-${USER_TYPE}}"
        JSON={"actionName":"createUser","authPass":"${tac_password}","authUser":"tadmin@talend.com","userFirstName":"$USER_FNAME","userLastName":"$USER_LNAME","userLogin":"$USER_LOGIN","userPassword":"$USER_PASSWD","userRole":["Administrator","Operation Manager","Designer"],"userType":"$USER_TYPE"}
        "${metaservlet_path}" --tac-url "${tac_url}" --json-params="${JSON}"
        echo "${USER_LOGIN} added: result $?"
    elif [ "${REQ_TYPE}" == "PROJECT" ]
    then
        PROJ=`echo $line | awk -F "," '{print $2}'`
        PROJ_TYPE=`echo $line | awk -F "," '{print $3}'`
        JSON={"actionName":"createProject","addTechNameAtURL":true,"authPass":"${tac_password}","authUser":"tadmin@talend.com","projectName":"$PROJ","projectType":"$PROJ_TYPE"}
        "${metaservlet_path}" --tac-url="${tac_url}" --json-params="${JSON}"
        echo "${PROJ} added: result $?"
    elif [ "${REQ_TYPE}" == "AUTH" ]
    then
        PROJ=`echo $line | awk -F "," '{print $2}'`
        USER_LOGIN=`echo $line | awk -F "," '{print $3}'`
        JSON={"actionName":"createAuthorization","authPass":"${tac_password}","authUser":"tadmin@talend.com","authorizationEntity":"User","authorizationType":"ReadWrite","groupLabel":"group","projectName":"${PROJ}","userLogin":"${USER_LOGIN}"}
        "${metaservlet_path}" --tac-url="${tac_url}" --json-params="${JSON}"
    fi
done < "${project_users_file}"
