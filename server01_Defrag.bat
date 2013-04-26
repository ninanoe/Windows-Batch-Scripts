@ECHO OFF

set defrag=defrag.exe
set driveA=C:
set driveB=D:
set driveC=X:

set smtpserver=mail.example.com
set emailfrom=admin@example.com
set emailto=admin@example.com
set emailprog=C:\Scripts\tools\blat.exe

REM ******************************************************************************************************************************
REM Windows Server 2003 does not automate the defragging process of your harddrives like in (2008 R2). So i build this script to do the same
REM
REM uses  http://www.blat.net/    for sending emails
REM ******************************************************************************************************************************

set dayname=%date:~0,2%
set month=%date:~6,2%
set day=%date:~3,2%
set year=%date:~9,4%

set hour=%time:~0,2%
set min=%time:~3,2%

set /a pyear=%date:~9,4%
if %date:~6,1%==0 (set /a pmonth=%date:~7,1%) else (set /a pmonth=%date:~6,2%)
set /a pmonth=%pmonth%-1
if %pmonth%==0 (set /a pyear=%pyear%-1)
if %pmonth%==0 (set /a pmonth=12)

REM Defrag
%defrag% %driveA% -a >%temp%\driveA.log
%defrag% %driveB% -a >%temp%\driveB.log
%defrag% %driveC% -a >%temp%\driveC.log

REM Check Defrag log
for /F "tokens=3 delims=:" %%A in ('find /C "You should defragment" "%temp%\driveA.log"') do set NR=%%A
if not "%NR%"==" 0" (
	%defrag% %driveA% -f >%temp%\driveA.log
	%emailprog% -body "Defragmentation harddrive %driveA% succesfull" -to %emailto% -f %emailfrom% -s "Defrag %driveA% / %COMPUTERNAME%" -attach "%temp%\driveA.log" -server %smtpserver%
)
for /F "tokens=3 delims=:" %%A in ('find /C "You should defragment" "%temp%\driveB.log"') do set NR=%%A
if not "%NR%"==" 0" (
	%defrag% %driveB% -f >%temp%\driveB.log
	%emailprog% -body "Defragmentation harddrive %driveB% succesfull" -to %emailto% -f %emailfrom% -s "Defrag %driveB% / %COMPUTERNAME%" -attach "%temp%\driveB.log" -server %smtpserver%
)
for /F "tokens=3 delims=:" %%A in ('find /C "You should defragment" "%temp%\driveC.log"') do set NR=%%A
if not "%NR%"==" 0" (
	%defrag% %driveC% -f >%temp%\driveC.log
	%emailprog% -body "Defragmentation harddrive %driveC% succesfull" -to %emailto% -f %emailfrom% -s "Defrag %driveC% / %COMPUTERNAME%" -attach "%temp%\driveC.log" -server %smtpserver%
)
del "%temp%\driveA.log"
del "%temp%\driveB.log"
del "%temp%\driveC.log"

exit