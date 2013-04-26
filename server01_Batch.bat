@ECHO OFF

set bkpfldr=x:\backups

REM ******************************************************************************************************************************
REM This is an example script to clean up servers.  I needed to stop some running processes and delete old backups (30days old)
REM uses deldate tool to delete files older then xx day
REM
REM http://www.petri.co.il/deldate.htm
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

REM Zaterdag en Zondag
IF %dayname%==za goto end
IF %dayname%==zo goto end


REM Kill a running task
taskkill /F /IM jopps.exe /T

REM Cleanup old backups
deldate /D30 %bkpfldr% > %temp%\deldate.txt
set /p deldatelog= < %temp%\deldate.txt
del %temp%\deldate.txt
eventcreate /L SYSTEM /T SUCCESS /ID 1 /SO "RE Del OLD Backups" /D "Delete OLD Backups. Computer: %computername% Log: %deldatelog%"

REM Cleanup by date APP Results
deldate /D180 D:\ExampleAPP\*
deldate /D180 /R D:\ExampleAPP\TEMP\*

REM Cleanup _QSQ Files
del /Q D:\ExampleAPP\_QSQ*
exit

:end
exit