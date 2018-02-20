#!/usr/bin/env bash

export TUI_CONFIG_amc_app__server_credentials_user=${TALEND_AMC_TOMCAT_MANAGER_USER}
export TUI_CONFIG_amc_app__server_credentials_password=${TALEND_AMC_TOMCAT_MANAGER_PASSWORD}
export TUI_CONFIG_amc_app__server_instance_name=$TALEND_AMC_NAME
export TUI_CONFIG_amc_app__server_instance_ports_http=${TALEND_AMC_PORT}
export TUI_CONFIG_amc_app__server_instance_webapp_name=$TALEND_AMC_WEBAPP_NAME
export TUI_CONFIG_amc_database_mariadb_schema=$TALEND_AMC_DB_SCHEMA
export TUI_CONFIG_amc_database_mariadb_host=$TALEND_AMC_DB_HOST
export TUI_CONFIG_amc_database_mariadb_port=$TALEND_AMC_DB_PORT
export TUI_CONFIG_amc_database_mariadb_username=$TALEND_AMC_DB_USER
export TUI_CONFIG_amc_database_mariadb_password=$TALEND_AMC_DB_PASSWORD
export TUI_CONFIG_amc_database_mysql_schema=$TALEND_AMC_DB_SCHEMA
export TUI_CONFIG_amc_database_mysql_host=$TALEND_AMC_DB_HOST
export TUI_CONFIG_amc_database_mysql_port=$TALEND_AMC_DB_PORT
export TUI_CONFIG_amc_database_mysql_username=$TALEND_AMC_DB_USER
export TUI_CONFIG_amc_database_mysql_password=$TALEND_AMC_DB_PASSWORD

export TUI_CONFIG_cmdline_logging_logstach_port=${TALEND_LOGSTASH_CMDLINE_PORT}
export TUI_CONFIG_cmdline__s_logging_logstach_port=${TALEND_LOGSTASH_CMDLINE_PORT}
export TUI_CONFIG_cmdline__ci_logging_logstach_port=${TALEND_LOGSTASH_CMDLINE_PORT}

export TUI_CONFIG_nexus_host=$TALEND_NEXUS_HOST
export TUI_CONFIG_nexus_port=$TALEND_NEXUS_PORT
export TUI_CONFIG_nexus_username=$TALEND_NEXUS_ADMIN
export TUI_CONFIG_nexus_password=$TALEND_NEXUS_PASSWORD
export TUI_CONFIG_nexus_url="http://${TALEND_NEXUS_HOST}:${TALEND_NEXUS_PORT}/nexus"

export TUI_CONFIG_tac_app__server_credentials_user=${TALEND_TAC_USERID}
export TUI_CONFIG_tac_app__server_credentials_password=${TALEND_TAC_PASSWORD}
export TUI_CONFIG_tac_app__server_instance_name=$TALEND_TAC_NAME
export TUI_CONFIG_tac_app__server_instance_ports_http=${TALEND_TAC_PORT}
export TUI_CONFIG_tac_app__server_instance_webapp_name=$TALEND_TAC_WEBAPP_NAME
export TUI_CONFIG_tac_database_mariadb_schema=$TALEND_TAC_DB_SCHEMA
export TUI_CONFIG_tac_database_mariadb_host=$TALEND_TAC_DB_HOST
export TUI_CONFIG_tac_database_mariadb_port=$TALEND_TAC_DB_PORT
export TUI_CONFIG_tac_database_mariadb_username=$TALEND_TAC_DB_USER
export TUI_CONFIG_tac_database_mariadb_password=$TALEND_TAC_DB_PASSWORD
export TUI_CONFIG_tac_database_mysql_schema=$TALEND_TAC_DB_SCHEMA
export TUI_CONFIG_tac_database_mysql_host=$TALEND_TAC_DB_HOST
export TUI_CONFIG_tac_database_mysql_port=$TALEND_TAC_DB_PORT
export TUI_CONFIG_tac_database_mysql_username=$TALEND_TAC_DB_USER
export TUI_CONFIG_tac_database_mysql_password=$TALEND_TAC_DB_PASSWORD
export TUI_CONFIG_tac_monitoring_kibana_port=$TALEND_LOGSTASH_KIBANA_PORT
export TUI_CONFIG_tac_logging_logstach_port=$TALEND_LOGSTASH_TAC_PORT

export TUI_CONFIG_tac_git_url=$TALEND_GIT_URL
export TUI_CONFIG_tac_git_host=$TALEND_GIT_HOST
export TUI_CONFIG_tac_git_port=$TALEND_GIT_PORT
export TUI_CONFIG_tac_git_repository=$TALEND_GIT_REPO
export TUI_CONFIG_tac_git_username=$TALEND_GIT_USER
export TUI_CONFIG_tac_git_password=$TALEND_GIT_PASSWORD

export TUI_CONFIG_tac_repository_nexus_host=${TALEND_NEXUS_HOST}
export TUI_CONFIG_tac_repository_nexus_port=${TALEND_NEXUS_PORT}
export TUI_CONFIG_tac_repository_nexus_url="http://${TALEND_NEXUS_HOST}:${TALEND_NEXUS_PORT}/nexus"
export TUI_CONFIG_tac_repository_nexus_username=${TALEND_NEXUS_ADMIN}
export TUI_CONFIG_tac_repository_nexus_password=${TALEND_NEXUS_PASSWORD}
export TUI_CONFIG_tac_softwareupdate_local_url="${TUI_CONFIG_tac_repository_nexus_url}"
# talend account for receiving updates provided only with commercial license
export TUI_CONFIG_tac_softwareupdate_talend_username=""
export TUI_CONFIG_tac_softwareupdate_talend_password=""
# anonymous local access
export TUI_CONFIG_tac_softwareupdate_local_deployment_username=""
export TUI_CONFIG_tac_softwareupdate_local_deployment_password=""
export TUI_CONFIG_tac_libraries_nexus_url="${TUI_CONFIG_tac_repository_nexus_url}"

export TUI_CONFIG_jobserver_host=$LOCAL_IPV4
export TUI_CONFIG_jobserver_logging_logstach_port=${TALEND_LOGSTASH_JOBSERVER_PORT}
export TUI_CONFIG_jobserver_tac__registration_label=$TALEND_JOBSERVER_LABEL

export TUI_CONFIG_logserver_elasticsearch_http_port=${TALEND_LOGSTASH_ELASTIC_SEARCH_PORT}
export TUI_CONFIG_logserver_kibana_server_port=$TALEND_LOGSTASH_KIBANA_PORT

export TUI_HOSTS_admin_host=$TALEND_TAC_HOST
export TUI_HOSTS_admin_database_host=$TALEND_TAC_DB_HOST
export TUI_HOSTS_admin_database_port=$TALEND_TAC_DB_PORT
export TUI_HOSTS_admin_database_schema__service=$TALEND_TAC_DB_SCHEMA
export TUI_HOSTS_admin_database_user=$TALEND_TAC_DB_USER
export TUI_HOSTS_admin_database_password=$TALEND_TAC_DB_PASSWORD

export TUI_HOSTS_logging_host=$TALEND_LOGGING_HOST

export TUI_HOSTS_monitoring_host=$TALEND_MONITORING_HOST
export TUI_HOSTS_monitoring_database_host=$TALEND_AMC_DB_HOST
export TUI_HOSTS_monitoring_database_port=$TALEND_AMC_DB_PORT
export TUI_HOSTS_monitoring_database_schema__service=$TALEND_AMC_DB_SCHEMA
export TUI_HOSTS_monitoring_database_user=$TALEND_AMC_DB_USER
export TUI_HOSTS_monitoring_database_password=$TALEND_AMC_DB_PASSWORD

echo TUI_CONFIG_amc_app__server_credentials_user=${TUI_CONFIG_amc_app__server_credentials_user}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_amc_app__server_credentials_password=${TUI_CONFIG_amc_app__server_credentials_password}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_amc_app__server_instance_name=${TUI_CONFIG_amc_app__server_instance_name}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_amc_app__server_instance_ports_http=${TUI_CONFIG_amc_app__server_instance_ports_http}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_amc_app__server_instance_webapp_name=${TUI_CONFIG_amc_app__server_instance_webapp_name}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_amc_database_mariadb_schema=${TUI_CONFIG_amc_database_mariadb_schema}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_amc_database_mariadb_host=${TUI_CONFIG_amc_database_mariadb_host}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_amc_database_mariadb_port=${TUI_CONFIG_amc_database_mariadb_port}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_amc_database_mariadb_username=${TUI_CONFIG_amc_database_mariadb_username}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_amc_database_mariadb_password=${TUI_CONFIG_amc_database_mariadb_password}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_amc_database_mysql_schema=${TUI_CONFIG_amc_database_mysql_schema}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_amc_database_mysql_host=${TUI_CONFIG_amc_database_mysql_host}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_amc_database_mysql_port=${TUI_CONFIG_amc_database_mysql_port}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_amc_database_mysql_username=${TUI_CONFIG_amc_database_mysql_username}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_amc_database_mysql_password=${TUI_CONFIG_amc_database_mysql_password}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_cmdline_logging_logstach_port=${TUI_CONFIG_cmdline_logging_logstach_port}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_cmdline__s_logging_logstach_port=${TUI_CONFIG_cmdline__s_logging_logstach_port}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_cmdline__ci_logging_logstach_port=${TUI_CONFIG_cmdline__ci_logging_logstach_port}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_nexus_host=${TUI_CONFIG_nexus_host}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_nexus_port=${TUI_CONFIG_nexus_port}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_nexus_username=${TUI_CONFIG_nexus_username}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_nexus_password=${TUI_CONFIG_nexus_password}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_app__server_credentials_user=${TUI_CONFIG_tac_app__server_credentials_user}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_app__server_credentials_password=${TUI_CONFIG_tac_app__server_credentials_password}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_app__server_instance_name=${TUI_CONFIG_tac_app__server_instance_name}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_app__server_instance_ports_http=${TUI_CONFIG_tac_app__server_instance_ports_http}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_app__server_instance_webapp_name=${TUI_CONFIG_tac_app__server_instance_webapp_name}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_database_mariadb_schema=${TUI_CONFIG_tac_database_mariadb_schema}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_database_mariadb_host=${TUI_CONFIG_tac_database_mariadb_host}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_database_mariadb_port=${TUI_CONFIG_tac_database_mariadb_port}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_database_mariadb_username=${TUI_CONFIG_tac_database_mariadb_username}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_database_mariadb_password=${TUI_CONFIG_tac_database_mariadb_password}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_database_mysql_schema=${TUI_CONFIG_tac_database_mysql_schema}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_database_mysql_host=${TUI_CONFIG_tac_database_mysql_host}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_database_mysql_port=${TUI_CONFIG_tac_database_mysql_port}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_database_mysql_username=${TUI_CONFIG_tac_database_mysql_username}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_database_mysql_password=${TUI_CONFIG_tac_database_mysql_password}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_monitoring_kibana_port=${TUI_CONFIG_tac_monitoring_kibana_port}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_logging_logstach_port=${TUI_CONFIG_tac_logging_logstach_port}  | tee -a "./tui_config_mapping.txt"

echo TUI_CONFIG_tac_git_url=${TUI_CONFIG_tac_git_url}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_git_host=${TUI_CONFIG_tac_git_host}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_git_port=${TUI_CONFIG_tac_git_port}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_git_repository=${TUI_CONFIG_tac_git_repository}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_git_username=${TUI_CONFIG_tac_git_username}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_git_password=${TUI_CONFIG_tac_git_password}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_git_url=${TUI_CONFIG_tac_git_url}  | tee -a "./tui_config_mapping.txt"

echo TUI_CONFIG_tac_repository_nexus_host=${TALEND_NEXUS_HOST} | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_repository_nexus_port=${TALEND_NEXUS_PORT} | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_repository_nexus_url="http://${TALEND_NEXUS_HOST}:${TALEND_NEXUS_PORT}/nexus" | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_repository_nexus_username=${TALEND_NEXUS_ADMIN} | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_repository_nexus_password=${TALEND_NEXUS_PASSWORD} | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_softwareupdate_local_url="${TUI_CONFIG_tac_repository_nexus_url}" | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_tac_libraries_nexus_url="${TUI_CONFIG_tac_repository_nexus_url}" | tee -a "./tui_config_mapping.txt"

echo TUI_CONFIG_jobserver_host=${TUI_CONFIG_jobserver_host}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_jobserver_logging_logstach_port=${TUI_CONFIG_jobserver_logging_logstach_port}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_jobserver_tac__registration_label=${TUI_CONFIG_jobserver_tac__registration_label}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_logserver_elasticsearch_http_port=${TUI_CONFIG_logserver_elasticsearch_http_port}  | tee -a "./tui_config_mapping.txt"
echo TUI_CONFIG_logserver_kibana_server_port=${TUI_CONFIG_logserver_kibana_server_port}  | tee -a "./tui_config_mapping.txt"
echo TUI_HOSTS_admin_host=${TUI_HOSTS_admin_host}  | tee -a "./tui_config_mapping.txt"
echo TUI_HOSTS_admin_database_host=${TUI_HOSTS_admin_database_host}  | tee -a "./tui_config_mapping.txt"
echo TUI_HOSTS_admin_database_port=${TUI_HOSTS_admin_database_port}  | tee -a "./tui_config_mapping.txt"
echo TUI_HOSTS_admin_database_schema__service=${TUI_HOSTS_admin_database_schema__service}  | tee -a "./tui_config_mapping.txt"
echo TUI_HOSTS_admin_database_user=${TUI_HOSTS_admin_database_user}  | tee -a "./tui_config_mapping.txt"
echo TUI_HOSTS_admin_database_password=${TUI_HOSTS_admin_database_password}  | tee -a "./tui_config_mapping.txt"
echo TUI_HOSTS_logging_host=${TUI_HOSTS_logging_host}  | tee -a "./tui_config_mapping.txt"
echo TUI_HOSTS_monitoring_host=${TUI_HOSTS_monitoring_host}  | tee -a "./tui_config_mapping.txt"
echo TUI_HOSTS_monitoring_database_host=${TUI_HOSTS_monitoring_database_host}  | tee -a "./tui_config_mapping.txt"
echo TUI_HOSTS_monitoring_database_port=${TUI_HOSTS_monitoring_database_port}  | tee -a "./tui_config_mapping.txt"
echo TUI_HOSTS_monitoring_database_schema__service=${TUI_HOSTS_monitoring_database_schema__service}  | tee -a "./tui_config_mapping.txt"
echo TUI_HOSTS_monitoring_database_user=${TUI_HOSTS_monitoring_database_user}  | tee -a "./tui_config_mapping.txt"
echo TUI_HOSTS_monitoring_database_password=${TUI_HOSTS_monitoring_database_password}  | tee -a "./tui_config_mapping.txt"



