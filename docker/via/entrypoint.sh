#!/bin/sh

cd /var/lib/via

cp /root/config.yaml ./

pip install --no-cache-dir -r requirements.txt
supervisord -c conf/supervisord.conf

