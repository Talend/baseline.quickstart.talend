#!/bin/bash

set -e
set -u
set -o pipefail

#service_path=$(readlink -e "${BASH_SOURCE[0]}")
#service_dir="${service_path%/*}"

#Human readable app name
export APP_NAME

#Pattern used to find pid of app
export APP_BASE=""

#User which application runs as
export APP_USER="talend"

#Command to launch service app
declare APP_START_CMD="/opt/talend/6.3.1/logserver/kibana-4.6.1-linux-x86_64/bin/kibana"

#Command to stop service
declare APP_STOP_CMD=""

#JAVA_HOME
export JAVA_HOME=/usr/bin/java_home

export PATH="${JAVA_HOME}/bin:${PATH}"

#SHUTDOWN_WAIT is wait time in seconds for java proccess to stop
declare SHUTDOWN_WAIT=60

#Sleep period between checking on process status
declare KILL_SLEEP_PERIOD=10




function user_exists() {
    id -u "${1}" >/dev/null 2>&1
    return "${?}"
}

function get_pid() {
    ps -fe | grep "${1}" | grep -v grep | tr -s " "|cut -d" " -f2
}

function pid_exists() {
    ps -p "${1}"
    return ${?}
}

function start() {
  local pid
  pid=$(get_pid "${APP_BASE}")
  if [ -n "${pid}" ]; then
    echo "${APP_NAME} is already running (pid: ${pid})"
  else
    # Start tomcat
    echo "Starting ${APP_NAME}"
    # ulimit -n 100000
    # umask 007
        if user_exists "${APP_USER}"; then
                su "${APP_USER}" -c "${APP_START_CMD}"
        else
                echo "User '${APP_USER}' does not exist. Starting with $(id)"
                "${APP_START_CMD}"
        fi
        status
  fi
  return 0
}

function status(){
    local pid
    pid=$(get_pid "${APP_BASE}")
    if [ -n "${pid}" ]; then
        echo "${APP_NAME} is running (pid: ${pid})"
    else
        echo "${APP_NAME} is not running"
        return 3
    fi
}

function terminate() {
    local pid
    pid=$(get_pid "${APP_BASE}")
    if [ -n "${pid}" ]; then
        echo "Terminating ${APP_NAME}"
        kill -9 "$(get_pid ${APP_BASE})"
    else
        echo "${APP_NAME} (${pid}) is not running"
    fi
}

stop() {
    local pid
    pid=$(get_pid "${APP_BASE}")
    if [ -n "${pid}" ]; then
        echo "Stoping ${APP_NAME}"
        if user_exists "${APP_USER}"; then
                su "${APP_USER}" -c "${APP_STOP_CMD}"
        else
                echo "User '${APP_USER}' does not exist. Stopping with $(id)"
                "${APP_STOP_CMD}"
        fi

    let kwait=${SHUTDOWN_WAIT}
    local count=0;
    until pid_exists "${pid}" || [ "${count}" -gt "${kwait}" ]
    do
      echo "Waiting for ${APP_NAME} (${pid}) process to exit";
      sleep "${KILL_SLEEP_PERIOD}"
      let count="${count}"+"${KILL_SLEEP_PERIOD}";
    done

    if [ "${count}" -gt "${kwait}" ]; then
      echo "${APP_NAME} (${pid}) did not stop after ${SHUTDOWN_WAIT} seconds"
      terminate
    fi
  else
    echo "${APP_NAME} (${pid}) is not running"
  fi
 
  return 0
}



case "${1}" in
	start)
	  start
	;;
	stop)
	  stop
	;;
	restart)
	  stop
	  start
	;;
	status)
		status
		exit $?
	;;
	kill)
		terminate
	;;
	*)
		echo "${APP_USAGE}"
	;;
esac

exit 0