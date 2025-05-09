#!/bin/bash

# Set input parameters
PG_USER="$1"
PG_PASSWORD="$2"
HOST_NAME=$3
PORT=$4

# Install dependencies
sudo yum update -y
sudo yum install postgresql-server -y
sudo yum install postgresql-contrib -y

# Set the file name and download link
FILENAME="hits.tsv"

# Check if the file exists
if [ ! -f "$FILENAME" ]; then
    echo "The file $FILENAME does not exist. Starting to download..."
    # 使用 curl 或 wget 下载文件
    wget --no-verbose --continue 'https://datasets.clickhouse.com/hits_compatible/hits.tsv.gz'
    gzip -d hits.tsv.gz
    chmod 777 ~ hits.tsv
    if [ $? -eq 0 ]; then
        echo "File download completed!"
    else
        echo "The download failed. Please check the URL or the network connection. "
        exit 1
    fi
else
    echo "The file $FILENAME already exists. Skipping the download."
fi

# create database and create table
PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d postgres  -t -c 'DROP DATABASE test'
sleep 15  # sleep for 15 seconds
PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d postgres  -t -c 'CREATE DATABASE test'
sleep 15  # sleep for 15 seconds
PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d test -t < create.sql

# sleep 15 seconds to wait for the database to be ready
sleep 15  # sleep for 15 seconds
echo "Starting to split the file..."

# split data
split -l 10000000  hits.tsv hits_part_

# load data
echo "Starting to load data..."

for file in hits_part_*; do
    PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d test -t -c '\timing' -c "\\copy hits FROM '$file'"
done

PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d test -t < prepare_sql.sql

# run clickbench test
echo "Starting to run queries..."

./run.sh $PG_USER $PG_PASSWORD $HOST_NAME $PORT 2>&1 | tee log.txt

cat log.txt | grep -oP '时间：\d+\.\d+ ms' | sed -r -e 's/时间：([0-9]+\.[0-9]+) ms/\1/' |
    awk '{ if (i % 3 == 0) { printf "[" }; printf $1 / 1000; if (i % 3 != 2) { printf "," } else { print "]," }; ++i; }' | tee result.txt