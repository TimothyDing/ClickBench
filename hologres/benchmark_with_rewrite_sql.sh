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

# run clickbench test with rewrite queries
echo "Starting to run queries with rewrite queries..."

./run_rewrite_queries.sh $PG_USER $PG_PASSWORD $HOST_NAME $PORT 2>&1 | tee log_rewrite_queries.txt

cat log_rewrite_queries.txt | grep -oP '时间：\d+\.\d+ ms' | sed -r -e 's/时间：([0-9]+\.[0-9]+) ms/\1/' |
    awk '{ if (i % 3 == 0) { printf "[" }; printf $1 / 1000; if (i % 3 != 2) { printf "," } else { print "]," }; ++i; }' | tee result_rewrite_queries.txt