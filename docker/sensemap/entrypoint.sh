#!/bin/bash

cd /workspace

yarn
# 替換API URL
PUBLIC_URL="" yarn run build
