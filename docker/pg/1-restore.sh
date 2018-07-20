#!/bin/sh -e

psql -f /docker-entrypoint-initdb.d/data/db.sql postgres
#cat /docker-entrypoint-initdb.d/db.data | pg_restore
