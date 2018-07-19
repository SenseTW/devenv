#!/bin/bash

cd /workspace
yarn

echo "Checking Database Connection ..."
while true; do
    CHECK_RESULT=$( yarn --silent run dbms:verify )
    if [ "$CHECK_RESULT" == "connected" ] || [ "$CHECK_RESULT" == "nodb" ]
    then
      echo "$CHECK_RESULT"
      break
    fi
    sleep 1s
done

yarn --silent run db:create
yarn run migrate up

echo "Start Sensemap Backend Service ..."

#tsc-watch --inlineSourceMap true --onSuccess "node --inspect=0.0.0.0:9229 ./dist/index.js" --onFailure "echo Beep! Compilation Failed"
concurrently 'yarn run tsc --inlineSourceMap true -w' 'yarn run nodemon -L --inspect=0.0.0.0:9229 --delay 2.5 --require ts-node/register dist'
#nodemon --watch 'src/**/*.ts' --exec "tsc --inlineSourceMap true && node --inspect=0.0.0.0:9229 --require ts-node/register dist"
#nodemon -L --watch '/workspace/src/**/*.ts' --exec "TS_NODE_COMPILER_OPTIONS='{\"inlineSourceMap\":\"true\"}' node --inspect=0.0.0.0:9229 --require ts-node/register dist"
