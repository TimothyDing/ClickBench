#!/bin/bash

PG_USER=$1
PG_PASSWORD=$2
HOST_NAME=$3
PORT=$4

TRIES=3

PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d test -t < prepare_sql.sql

cat queries.sql | while read query; do
    sync
    echo 3 | PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d test -t < freecache.sql

    echo "$query";
    for i in $(seq 1 $TRIES); do
        PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d test -t -c '\timing' -c "$query" | grep 'ms'
    done;
done;