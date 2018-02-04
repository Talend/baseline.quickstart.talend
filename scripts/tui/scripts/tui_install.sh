#!/usr/bin/env bash

set -e
umask 037
. /etc/profile.d/jre.sh
. ./setenv.sh
. ./instance-env.sh
. ./server-env.sh
. /home/ubuntu/tui/conf/6.3.1/tui_config_mappings.sh
./install -q 6.3.1 studio
chown -R ubuntu:ubuntu /opt/talend
chmod u+x /opt/talend/6.3.1/studio/studio/Talend-Studio-linux-gtk-x86_64

