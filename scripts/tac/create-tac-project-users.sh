#!/bin/sh

set -e
set -x

script_path=$(readlink -e "${BASH_SOURCE[0]}")
script_dir="${script_path%/*}"

declare project_users_file="${1:-${script_dir}/project-users.data}"

declare usage="create-tac-project-users.sh <project_users_file>"

[ -z "${project_users_file}" ] && echo "project users data file argument required: usage: ${usage}" && exit

[ ! -f "${project_users_file}" ] && echo "project users data file argument '${projects_users_file}' does not exist" && exit

declare tac_url="http://localhost:8080/tac"
declare metaservlet_path="/opt/talend/6.3.1/tac/webapps/tac/WEB-INF/classes/MetaServletCaller.sh"
chmod 750 "${metaservlet_path}"

while read line
do
    REQ_TYPE=`echo $line | awk -F "," '{print $1}'`
    if [ $REQ_TYPE == USER ]
    then
        USER_FNAME=`echo $line | awk -F "," '{print $2}'`
        USER_LNAME=`echo $line | awk -F "," '{print $3}'`
        USER_LOGIN=`echo $line | awk -F "," '{print $4}'`
        USER_PASSWD=`echo $line | awk -F "," '{print $5}'`
        USER_TYPE=`echo $line | awk -F "," '{print $6}'`
        JSON={"actionName":"createUser","authPass":"admin","authUser":"admin@company.com","userFirstName":"$USER_FNAME","userLastName":"$USER_LNAME","userLogin":"$USER_LOGIN","userPassword":"$USER_PASSWD","userRole":["Administrator","Operation Manager","Designer"],"userType":"$USER_TYPE"}
        ${metaservlet_path} --tac-url "${tac_url}" --json-params="${JSON}"
        echo "result $?"
    elif [ $REQ_TYPE == PROJECT ]
    then
        PROJ=`echo $line | awk -F "," '{print $2}'`
        PROJ_TYPE=`echo $line | awk -F "," '{print $3}'`
        JSON={"actionName":"createProject","addTechNameAtURL":true,"authPass":"admin","authUser":"admin@company.com","projectName":"$PROJ","projectType":"$PROJ_TYPE"}
        ${metaservlet_path} --tac-url="${tac_url}" --json-params="${JSON}"
        echo "result $?"
    fi
done < "${project_users_file}"
