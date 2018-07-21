#!/bin/bash

sshfs wenchenx@192.168.88.160:/home/wenchenx/devenv sensetw-devenv
code sensetw-devenv

ssh -L 9200:127.0.0.1:9200 \
    -L 9230:127.0.0.1:9230 \
    -L 5672:127.0.0.1:5672 \
    -L 15672:127.0.0.1:15672 \
    -L 5432:127.0.0.1:5432 \
    -L 8000:127.0.0.1:8000 \
    -L 8010:127.0.0.1:8010 \
    -L 8020:127.0.0.1:8020 \
    -L 8030:127.0.0.1:8030 \
    -L 8040:127.0.0.1:8040 \
    wenchenx@192.168.88.160

umount sensetw-devenv
