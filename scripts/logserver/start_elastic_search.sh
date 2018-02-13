#!/usr/bin/env bash

set -e
set -u

es_script_path=$(readlink -e "${BASH_SOURCE[0]}")
es_script_dir="${es_script_path%/*}"

talend_version=6.3.1

source /opt/talend/set-env-${talend_version}.sh

CURL=${es_script_dir}/utils/curl-7.50.3-linux-x86_64.bin

#
# Use OS curl as the curl in the 'util' folder may require libraries not available on this OS
# With error like:
# /lib64/libc.so.6: version `GLIBC_2.14' not found (required by <install path>/utils/curl-7.50.3-linux-x86_64.bin)
#
if [ -z "`which curl | grep -e 'no curl'`" ]; then
    CURL=curl
fi

function parse_metadata_result() {
    local metadata="${1}"
    local value="${metadata#*: }"
    echo "${value}"
}

declare local_hostname
local_hostname=$("${es_script_dir}/ec2-metadata" -h)
local_hostname=$(parse_metadata_result "${local_hostname}")


ES_HOME=${es_script_dir}/elasticsearch-2.4.0
ES_HOST="http://${local_hostname}:9200"
ES_LOG=/var/talend/${talend_version}/logserver/elasticsearch/logs/elasticsearch.log


wait_for_es() {
    local nperiods="${1:-30}"
    local sleep_period="${2:-2}"
    unset started
    for i in `seq "${nperiods}"`; do
        if [ -n "`${CURL} -XGET ${ES_HOST}/_cat/health 2>&1 | grep -e 'green' -e 'yellow' -e 'red'`" ]; then
            started=1
            break;
        fi
        sleep "${sleep_period}"
    done
    if [ ${started:-0} = "1" ]; then
        return
    else
        echo "failed to start Elasticsearch" >&2
        exit 1
    fi
}

# start ES
export ES_JAVA_OPTS="-Dmapper.allow_dots_in_name=true"
${ES_HOME}/bin/elasticsearch -d
wait_for_es

# create/update template for logstash-* indices
${CURL} -v -XPUT ${ES_HOST}/_template/template_logstash -d @template_logstash.json >> $ES_LOG 2>&1
# create/update template for talendesb-* indices
${CURL} -v -XPUT ${ES_HOST}/_template/template_esb -d @template_talendesb.json >> $ES_LOG 2>&1

#
# Kibana pre-configuration
#

wait_for_index() {
    local nperiods="${1:-30}"
    local sleep_period="${2:-2}"
    unset started
    for i in `seq "${nperiods}"`; do
        if [ -z "`${CURL} -s -XGET ${ES_HOST}/.kibana/_count | grep status | grep 503`" ]; then
            started=1
            break;
        fi
        sleep "${sleep_period}"
    done
    if [ ${started:-0} = "1" ]; then
        return
    else
        echo "failed to query Elasticsearch index" >&2
        exit 1
    fi
}


# create .kibana index if needed
${CURL} -v -XPUT ${ES_HOST}/.kibana >> $ES_LOG 2>&1
wait_for_index

# import kibana objects
# 0. index-pattern
for f in `find ./kibana-objects/index-pattern -name "*.json"`; do
    name=`cat $f | grep "title" | sed -e 's/.*\"title\"[^\"]*\"\(.*\)\".*/\1/'`
    if [ -z "$name" ]; then
        name=`basename $f .json`
    fi
    search=`${CURL} -s -XGET ${ES_HOST}/.kibana/_count?pretty -d "{\"query\": {\"bool\": {\"filter\": [{\"term\": {\"_type\": \"index-pattern\"}}, {\"term\": {\"_id\": \"$name\"}}]}}}" | grep count | grep 0`
    if [ -n "$search" ]; then
        ${CURL} -v -XPUT ${ES_HOST}/.kibana/index-pattern/$name -d @$f >> $ES_LOG 2>&1
    fi
done

# default index-pattern
name="logstash-*"
${CURL} -v -XPUT ${ES_HOST}/.kibana/config/4.6.1 -d '{"defaultIndex" : "logstash-*"}' >> $ES_LOG 2>&1

# 1. searches
for f in `find ./kibana-objects/search -name "*.json"`; do
    name=`basename $f .json`
    search=`${CURL} -s -XGET ${ES_HOST}/.kibana/_count?pretty -d "{\"query\": {\"bool\": {\"filter\": [{\"term\": {\"_type\": \"search\"}}, {\"term\": {\"_id\": \"$name\"}}]}}}" | grep count | grep 0`
    if [ -n "$search" ]; then
        ${CURL} -v -XPUT ${ES_HOST}/.kibana/search/$name -d @$f >> $ES_LOG 2>&1
    fi
done
# 2. visualizations
for f in `find ./kibana-objects/visualization -name "*.json"`; do
    name=`basename $f .json`
    search=`${CURL} -s -XGET ${ES_HOST}/.kibana/_count?pretty -d "{\"query\": {\"bool\": {\"filter\": [{\"term\": {\"_type\": \"visualization\"}}, {\"term\": {\"_id\": \"$name\"}}]}}}" | grep count | grep 0`
    if [ -n "$search" ]; then
        ${CURL} -v -XPUT ${ES_HOST}/.kibana/visualization/$name -d @$f >> $ES_LOG 2>&1
    fi
done
# 3. dashboards
for f in `find ./kibana-objects/dashboard -name "*.json"`; do
    name=`basename $f .json`
    search=`${CURL} -s -XGET ${ES_HOST}/.kibana/_count?pretty -d "{\"query\": {\"bool\": {\"filter\": [{\"term\": {\"_type\": \"dashboard\"}}, {\"term\": {\"_id\": \"$name\"}}]}}}" | grep count | grep 0`
    if [ -n "$search" ]; then
        ${CURL} -v -XPUT ${ES_HOST}/.kibana/dashboard/$name -d @$f >> $ES_LOG 2>&1
    fi
done
