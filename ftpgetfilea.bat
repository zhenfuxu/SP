echo open 192.168.1.104>F:\xzf\bat\%1.ftp
echo xuzhenfu>>F:\xzf\bat\%1.ftp
echo 1234554321>>F:\xzf\bat\%1.ftp
echo quote PASV>>F:\xzf\bat\%1.ftp
echo prompt off>>F:\xzf\bat\%1.ftp
if %3 GTR 0 (
echo cd 15min>>F:\xzf\bat\%1.ftp
) else (
echo cd 1hour>>F:\xzf\bat\%1.ftp
)
echo get %2>>F:\xzf\bat\%1.ftp
echo quit>>F:\xzf\bat\%1.ftp

FTP -s:F:\xzf\bat\%1.ftp>>F:\xzf\bat\log%1.txt

@echo off
if exist "%2" (
echo y
call F:\xzf\bat\psqlcopyfile.bat %1 %2
del %2
) else (
echo not exist "%2"
)
