#!/bin/bash

OS=`uname -s`

if  ([ "$OS" == "Darwin" ] || (grep -q "host.docker.internal" /etc/hosts))
then
    echo "✔︎ no need to update /etc/hosts"
else
    echo "You may be asked to add a password (sudo command executed)"
    sudo sh -c 'echo "$(dig +short `hostname` | head -n1) host.docker.internal"  >> /etc/hosts'
    echo "✔︎ /etc/hosts updated"
fi

rm -rf cp-demo
git clone https://github.com/confluentinc/cp-demo
echo "✔︎ cp-demo cloned"

cd cp-demo
git checkout 7.4.0-post
echo "✔︎ CP 7.4.0 defined"

if  [ "$OS" == "Linux" ]
then
    sed -i 's/,dns:localhost/,dns:localhost,dns:host.docker.internal/g' scripts/security/certs-create-per-user.sh
    sed -i 's/"DNS.4 = kafka2"/"DNS.4 = kafka2" "DNS.5 = host.docker.internal"/g' scripts/security/certs-create-per-user.sh
else
    sed -i '' 's/,dns:localhost/,dns:localhost,dns:host.docker.internal/g' scripts/security/certs-create-per-user.sh
    sed -i '' 's/"DNS.4 = kafka2"/"DNS.4 = kafka2" "DNS.5 = host.docker.internal"/g' scripts/security/certs-create-per-user.sh
fi

export CLEAN="true" && export C3_KSQLDB_HTTPS="false" && export VIZ="false" && ./scripts/start.sh
cd ..
