#!/bin/bash

# 设置入参
PG_USER="$1"
PG_PASSWORD="$2"
HOST_NAME=$3
PORT=$4

# 安装依赖
yum update -y
yum install postgresql-server -y
yum install postgresql-contrib -y

# 设置文件名和下载链接
FILENAME="hits.tsv"

# 检查文件是否存在
if [ ! -f "$FILENAME" ]; then
    echo "文件 $FILENAME 不存在，开始下载..."
    # 使用 curl 或 wget 下载文件
    wget --no-verbose --continue 'https://datasets.clickhouse.com/hits_compatible/hits.tsv.gz'
    gzip -d hits.tsv.gz
    chmod 777 ~ hits.tsv
    if [ $? -eq 0 ]; then
        echo "文件下载完成！"
    else
        echo "下载失败，请检查 URL 或网络连接。"
        exit 1
    fi
else
    echo "文件 $FILENAME 已存在，跳过下载。"
fi

# 创建数据库
PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d postgres  -t -c 'DROP DATABASE test'
PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d postgres  -t -c 'CREATE DATABASE test'
PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d test -t < create.sql

# Sleep 15 秒等待DDL同步
echo "开始执行脚本..."
sleep 15  # 暂停 15 秒
echo "15 秒后继续执行..."

# 文件切片
split -l 10000000  hits.tsv hits_part_

# 文件导入
for file in hits_part_*; do
    PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d test -t -c '\timing' -c "\\copy hits FROM '$file'"
done

PGUSER=$PG_USER PGPASSWORD=$PG_PASSWORD psql -h $HOST_NAME -p $PORT -d test -t < prepare_sql.sql

# COPY 99997497
# Time: 2341543.463 ms (39:01.543)

./run.sh $PG_USER $PG_PASSWORD $HOST_NAME $PORT 2>&1 | tee log.txt

cat log.txt | grep -oP '时间：\d+\.\d+ ms' | sed -r -e 's/时间：([0-9]+\.[0-9]+) ms/\1/' |
    awk '{ if (i % 3 == 0) { printf "[" }; printf $1 / 1000; if (i % 3 != 2) { printf "," } else { print "]," }; ++i; }' | tee resoult.txt