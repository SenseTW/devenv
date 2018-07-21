#!/bin/bash

if [ -x "$(command -v docker)" ]; then
    # command
    if [ ! "$(docker ps)" ]; then
        echo "Start your Docker Demon before running the install-script"
        exit;
    fi
else
    echo "Install docker and start it before running the install-script"
    open "https://store.docker.com/editions/community/docker-ce-desktop-mac"
    exit;
fi

mkdir -p data
mkdir -p data/pgdata
mkdir -p data/elastic

# Pull all subbmodules
git submodule update --recursive --remote

# Build API Image
docker build -t sensetw-api docker/sensemap-backend/.

# Build Sensemap Image
docker build -t sensemap docker/sensemap/.

# Build H Client Image
docker build -t h-client docker/h-client/.

# Build H via Image
docker build -t via docker/via/.

# Build H Image
docker build -t h docker/h/.

