#!/bin/sh

set -e
set -x

script_path=$(readlink -e "${BASH_SOURCE[0]}")
script_dir="${script_path%/*}"

declare tac_password="${1:-}"
declare project_users_file="${2:-${script_dir}/project-users.data}"

declare usage="create-tac-project-users.sh <project_users_file>"

[ -z "${tac_password}" ] && echo "tac_password required: usage: ${usage}" && exit 1

[ -z "${project_users_file}" ] && echo "project users data file argument required: usage: ${usage}" && exit 1

[ ! -f "${project_users_file}" ] && echo "project users data file argument '${projects_users_file}' does not exist" && exit 1

declare tac_url="http://localhost:8080/tac"
declare metaservlet_path="/opt/talend/6.3.1/tac/webapps/tac/WEB-INF/classes/MetaServletCaller.sh"
chmod 750 "${metaservlet_path}"

# todo: refactor to function

# create tadmin with password from environment

USER_FNAME="Talend"
USER_LNAME="Administrator"
USER_LOGIN="tadmin@talend.com"
USER_PASSWD="${tac_password}"
USER_TYPE="DI"
JSON={"actionName":"createUser","authPass":"admin","authUser":"admin@company.com","userFirstName":"$USER_FNAME","userLastName":"$USER_LNAME","userLogin":"$USER_LOGIN","userPassword":"$USER_PASSWD","userRole":["Administrator","Operation Manager","Designer"],"userType":"$USER_TYPE"}
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
