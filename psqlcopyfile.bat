
@set pghost=192.168.1.104
@set pguser=msgservice
@set pgdbname=msgservice
@set PGPASSWORD=msgservice

:::\copy zby_norm_1limit_net_hour from zby_norm_1limit_net_hour_2019091615_end.csv DELIMITER '|';
echo \copy %1 from %2 DELIMITER '^|'; >F:\xzf\bat\sql/%1.sql
rem start copy csv %1
:::@echo off
psql -U %pguser% -h %pghost% -d %pgdbname% -f F:\xzf\bat\sql/%1.sql

:::del %2>>log.txt
