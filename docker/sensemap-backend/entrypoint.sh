#!/bin/bash

cd /workspace
yarn

echo "Checking Database Connection ..."
while true; do
    CHECK_RESULT=$( yarn --silent run dbms:verify )
    if [ "$CHECK_RESULT" == "connected" ]
    then
      echo "$CHECK_RESULT"
      break
    fi
    sleep 1s
done

yarn --silent run db:create
yarn run migrate up

echo "Start Sensemap Backend Service ..."
yarn run concurrently 'tsc --inlineSourceMap true -w' 'nodemon --inspect-brk=0.0.0.0:9229 --require ts-node/register dist'
