#!/bin/bash

yum update -y
yum install postgresql-server -y
yum install postgresql-contrib -y

wget --no-verbose --continue 'https://datasets.clickhouse.com/hits_compatible/hits.tsv.gz'
gzip -d hits.tsv.gz
chmod 777 ~ hits.tsv

PG_USER="$1"
PG_PASSWORD="$2"
HOST_NAME=$3
PORT=$4

PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d postgres  -t -c 'CREATE DATABASE ssb'
PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d ssb -t < create.sql
PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d ssb -t -c '\timing' -c "\\copy hits FROM 'hits.tsv'"

PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d ssb -t -c 'VACUUM hits'
PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d ssb -t -c 'ANALYZE hits'

# COPY 99997497
# Time: 2341543.463 ms (39:01.543)

./run.sh $PG_USER $PG_PASSWORD $HOST_NAME $PORT 2>&1 | tee log.txt

cat log.txt | grep -oP 'Time: \d+\.\d+ ms' | sed -r -e 's/Time: ([0-9]+\.[0-9]+) ms/\1/' |
    awk '{ if (i % 3 == 0) { printf "[" }; printf $1 / 1000; if (i % 3 != 2) { printf "," } else { print "]," }; ++i; }' | tee resoult.txt
