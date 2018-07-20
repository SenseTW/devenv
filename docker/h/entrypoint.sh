#!/bin/sh

cd /var/lib/hypothesis

if [ ! -f /var/lib/hypothesis/build/manifest.json ]; then
    npm install
    gulp build
    npm cache clean
fi

while ! pg_isready -h db -p 5432 > /dev/null 2> /dev/null; do
    echo "Waiting for psql://db:5432/ ..."
    sleep 3
done

until $(curl --output /dev/null --silent --head --fail http://elastic:9200); do
    printf 'Waiting for Elastic http://elastic:9200/ ...'
    sleep 3
done

hypothesis init
init-env supervisord -c /supervisord.conf
