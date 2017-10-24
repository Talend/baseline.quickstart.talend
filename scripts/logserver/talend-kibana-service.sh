#!/bin/bash

set -e
set -u

# requires sudo
[ "$(id -u)" -ne 0 ] && echo "talend-kibana-service must be run as root" && exit

#service_path=$(readlink -e "${BASH_SOURCE[0]}")
#service_dir="${service_path%/*}"

#Human readable app name
export APP_NAME="kibana"

#Pattern used to find pid of app
export PID_PATTERN="kibana-4.6.1"

#Lock directory
export LOCK_DIR="/var/lock/subsys"

#Lockfile name
export LOCK_FILE="kibana-4.6.1"

#User which application runs as
export APP_USER="talend"

#Command to launch service app
declare APP_START_CMD="/opt/talend/6.3.1/logserver/kibana-4.6.1-linux-x86_64/bin/kibana"

#Command to stop service
declare APP_STOP_CMD=""

#Usage help message
declare APP_USAGE="${BASH_SOURCE[0]} start|stop|status|reload|restart"

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
    ps -p "${1}" > /dev/null 2>&1
    return ${?}
}

function save_pid() {
    echo "${pid}" > "${LOCK_DIR}/${LOCK_FILE}"
}

define(){ IFS=$'\n' read -r -d '' "${1}" || true; }

function read_pid() {
    [ -r "${LOCK_DIR}/${LOCK_FILE}" ] && define pid < "${LOCK_DIR}/${LOCK_FILE}" || pid=""
}

function is_locked() {
    [ -e "${LOCK_DIR}/${LOCK_FILE}" ] && return 0
    return 1
}

function lock() {
    echo "${pid}" > "${LOCK_DIR}/${LOCK_FILE}"
}

function unlock() {
    is_locked && rm -f "${LOCK_DIR}/${LOCK_FILE}" || echo "WARNING: no lock file found ${LOCK_DIR}/${LOCK_FILE}"
}

# calling function must define pid variable
function start_service() {
    # ulimit -n 100000
    # umask 007
    if [ -n "${APP_USER}" ] && user_exists "${APP_USER}"; then
        # todo this will probably not get the correct pid because of the sudo
#        sudo -E -u "${APP_USER}" -b "${APP_START_CMD}"
        su "${APP_USER}" -p -c "${APP_START_CMD}" &
        pid="${!}"
    elif [ -z "${APP_USER}" ]; then
        "${APP_START_CMD}" &
        pid="${!}"
    else
        echo "WARNING: user '${APP_USER}' does not exist. Starting with $(id)" >&2
        "${APP_START_CMD}" &
        pid="${!}"
    fi
}

# calling function must define pid variable
function stop_service() {
    if [ -n "${APP_STOP_CMD}" ]; then
        if user_exists "${APP_USER}"; then
            sudo -u "${APP_USER}" "${APP_USER}" -c "${APP_STOP_CMD}"
        elif [ -n "${APP_STOP_CMD}" ]; then
            echo "User '${APP_USER}' does not exist.  Stopping with user $(id)"
            "${APP_STOP_CMD}"
        fi
        return "${?}"
    elif [ -n "${pid}" ]; then
        kill "${pid}"
    else
        echo "ERROR: no APP_STOP_CMD defined and no pid provided."
        return 1
    fi
}

function start() {
    local pid
    read_pid || pid=$(get_pid "${PID_PATTERN}")
    if [ -n "${pid}" ] && [ -e "${LOCK_DIR}/${LOCK_FILE}" ]; then
        echo "${APP_NAME} is already running (pid: ${pid})"
        return 0
    elif [ -n "${pid}" ]; then
        echo "WARNING: ${APP_NAME} (pid: ${pid}) is running, but lock file ${LOCK_DIR}/${LOCK_FILE} does not exist.  New lock file created." 1>&2
        lock
        return 0
    elif [ -e "${LOCK_DIR}/${LOCK_FILE}" ]; then
        echo "WARNING: ${APP_NAME} is not running, but lock file ${LOCK_DIR}/${LOCK_FILE} exists.  Lock file will be removed." 1>&2
        unlock
    fi

    echo "Starting ${APP_NAME}"
    start_service
    lock
    status

    return 0
}

# 0     program is running or service is OK
# 1     program is dead and /var/run pid file exists
# 2     program is dead and /var/lock lock file exists
# 3     program is not running
# 4     program or service status is unknown
# 5-99  reserved for future LSB use
# 100-149       reserved for distribution use
# 150-199       reserved for application use
# 200-254       reserved

function status(){
    local pid
    read_pid
    if [ -n "${pid}" ] && pid_exists "${pid}"; then
        echo "${APP_NAME} (pid: ${pid}) is running"
        return 0
    elif [ -n "${pid}" ]; then
        echo "WARNING: ${APP_NAME} lock file ${LOCK_DIR}/${LOCK_FILE} exists but (pid: ${pid}) is not running.  Removing lock file."
        unlock
        return 3
    else
        pid=$(get_pid "${PID_PATTERN}")
        if [ -n "${pid}" ]; then
            echo "WARNING: ${APP_NAME} (pid: ${pid}) is running, but lock file ${LOCK_DIR}/${LOCK_FILE} does not exist.  New lock file created."
            lock
            return 0
        else
            echo "${APP_NAME} is not running"
            return 3
        fi
    fi
}

function terminate() {
    local pid
    read_pid || pid=$(get_pid "${PID_PATTERN}")
    if [ -z "${pid}" ]; then
        if is_locked; then
            echo "WARNING: ${APP_NAME} is not running but lock file exists.  Removing lock file."
            unlock
        else
            echo "${APP_NAME} is not running"
        fi
    else
        echo "Terminating ${APP_NAME} (${pid})"
        kill -9 "${pid}"
        unlock
    fi
}

stop() {
    local pid
    read_pid || pid=$(get_pid "${PID_PATTERN}")
    if [ -z "${pid}" ]; then
        echo "${APP_NAME} is not running"
        return 0
    fi

    echo "Stopping ${APP_NAME} (${pid})"
    stop_service

    let kwait=${SHUTDOWN_WAIT}
    local count=0;
    while pid_exists "${pid}" && [ "${count}" -lt "${kwait}" ]; do
        echo "Waiting for ${APP_NAME} (${pid}) process to exit";
        sleep "${KILL_SLEEP_PERIOD}"
        let count="${count}"+"${KILL_SLEEP_PERIOD}";
    done

    if pid_exists "${pid}"; then
        echo "${APP_NAME} (${pid}) did not stop after ${SHUTDOWN_WAIT} seconds"
        terminate
    else
        unlock
    fi

    return 0
}



case "${1}" in
    start)
        start
        exit $?
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
