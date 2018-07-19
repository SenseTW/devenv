#!/bin/sh

cd /var/lib/hypothesis

if [ ! -f /var/lib/hypothesis/build/manifest.json ]; then
    npm install
    gulp build
    npm cache clean
fi


init-env supervisord -c /supervisord.conf
