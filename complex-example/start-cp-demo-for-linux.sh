#!/bin/bash

# if [ "$EUID" -ne 0 ]
#   then echo "Please run as root"
#   exit
# fi

if  grep -q "host.internal.docker" /etc/hosts
then
    echo "✔︎ no need to update /etc/hosts"
else
    sudo echo "$(dig +short `hostname` | head -n1) host.docker.internal"  >> /etc/hosts
    echo "✔︎ /etc/hosts updated"
fi

./start-cp-demo-common.sh
