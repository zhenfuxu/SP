#!/bin/bash

# MySQL username and password. chmod this script to 0700.
USERNAME="root"
PASSWORD="EWDPASS"
HOSTIP="localhost"
MYSQL_BASE="/usr/bin/mysql -u $USERNAME -p$PASSWORD -h $HOSTIP"
MYSQLDUMP_BASE="/usr/bin/mysqldump -u $USERNAME -p$PASSWORD -h $HOSTIP"

BACKUP_DATE=$(date +'%Y_%m_%d')
BASE_DIR="/tomcat/backups/sql/$BACKUP_DATE"
BACKUP_DIR="$BASE_DIR/data"
BACKUP_DIR_NODATA="$BASE_DIR/nodata"

# If you want to exclude databases, just add them to the egrep expression, pipe separated
BACKUP_DBS=$($MYSQL_BASE -e 'show databases;'|/bin/egrep -vi "(\+|database|information_schema|mysql|performance_schema|sys)")

# Remove backups older than 10 days
/usr/bin/find $BACKUP_DIR -maxdepth 1 -type d -mtime +9 -exec rm -rf {} \;

# Backup
for db in $BACKUP_DBS
do
  # data
  DB_DIR="$BACKUP_DIR/$db"
  # nodata
  DB_DIR_NODATA="$BACKUP_DIR_NODATA/$db"
  TABLES=$($MYSQL_BASE -D $db -e 'show tables;'|/bin/egrep -vi "(\+|tables)")

  # Creating directory and dumping tables
  /bin/mkdir -p $DB_DIR
  /bin/mkdir -p $DB_DIR_NODATA
  $MYSQLDUMP_BASE --single-transaction $db |/bin/gzip -9 > $DB_DIR/$db.gz
  $MYSQLDUMP_BASE --single-transaction --no-data $db |/bin/gzip -9 > $DB_DIR_NODATA/$db.gz
  for table in $TABLES
  do
        # data
    $MYSQLDUMP_BASE --single-transaction --add-drop-table $db $table|/bin/gzip -9 > $DB_DIR/$table.gz
    # nodata
        $MYSQLDUMP_BASE --single-transaction --no-data --add-drop-table  $db $table|/bin/gzip -9 > $DB_DIR_NODATA/$table.gz
  done
done

# 压缩数据库文件
tar -czf /tomcat/backups/sql/$BACKUP_DATE.tar.gz /tomcat/backups/sql/$BACKUP_DATE

# ftp -n<<!
# open 10.230.94.xx
# user dns xxxxxxx
# binary
# lcd /tomcat/backups/sql
# prompt off
# put $BACKUP_DATE.tar.gz
# close
# bye
# !
# if [ $? -eq 0 ]; then
     # echo "ftp put file succeed"
# else
     # echo "ftp put file failed"
# fi
