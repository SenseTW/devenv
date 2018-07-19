#!/bin/bash

docker-compose down
rm -rf data
docker rmi $(docker images | grep "none" | awk '/ / { print $3 }')
docker rmi h
docker rmi h-client
docker rmi sensetw-api
docker rmi via
