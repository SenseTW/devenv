#!/bin/bash

cp -rf /opt/client-conf/* /workspace/

cd /workspace
npm install
npm install gulp

export NODE_ENV=development
export SIDEBAR_APP_URL=http://localhost:8000/app.html

service nginx start

#make clean
gulp watch
