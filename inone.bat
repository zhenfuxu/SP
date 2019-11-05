:::del log.txt
Echo SETTING DATE>>F:\xzf\bat\log%1.txt
@set yyyy=%date:~0,4%
@set mm=%date:~5,2%
@set dd=%date:~8,2%
@set hh=%time:~0,2%
@set mi=%time:~3,2%
@set pghost=192.168.1.104
@set pguser=msgservice
@set pgdbname=msgservice
@set PGPASSWORD=msgservice
@echo on
for /F "tokens=1-3 delims=:." %%a in ("%time%") do (
   set timeHour=%%a
   set timeMinute=%%b
   set timeSeconds=%%c
)
:::set timeMinute=0
:::rem Convert HH:MM to minutes + 5
set /A newTime=timeHour*60 + timeMinute + -10
:::rem Convert new time back to HH:MM
set /A timeHour=newTime/60, timeMinute=newTime%%60
:::rem Adjust new hour and minute
if %timeHour% gtr 23 set timeHour=0
if %timeHour% lss 10 set timeHour=0%timeHour%
if %timeMinute% lss 10 set timeMinute=0%timeMinute%
:::echo %timeHour%:%timeMinute%:%timeSeconds%

ECHO DATE SET >>F:\xzf\bat\log%1.txt

echo DATE SET AS YEAR %yyyy%; MONTH %mm%; DAY %dd%; >>F:\xzf\bat\log%1.txt

set fileName=%1_%yyyy%%mm%%dd%%timeHour%%timeMinute%_end.csv
:::echo %fileName%

if %2 GTR 0 (
goto Minutefor
) else (
goto Hourfor
)
:Hourfor
set fileName=%1_%yyyy%%mm%%dd%%timeHour%_end.csv
:::echo %fileName%

for /F "skip=2 delims=" %%a in ('psql -U %pguser% -h %pghost% -d %pgdbname% -c "select count(*) FROM public.%1 where columa='%yyyy%-%mm%-%dd% %timeHour%:00'"') do (
	set linea=%%a
	goto REnd
)
:Minutefor
for /F "skip=2 delims=" %%a in ('psql -U %pguser% -h %pghost% -d %pgdbname% -c "select count(*) FROM public.%1 where columa='%yyyy%-%mm%-%dd% %timeHour%:%timeMinute%'"') do (
	set linea=%%a
	goto REnd
)
:REnd
echo %linea%
if %linea% GTR 0 (
goto STOP
) else (
call F:\xzf\bat\ftpgetfilea.bat %1 %fileName% %2
)
:STOP
:::exit