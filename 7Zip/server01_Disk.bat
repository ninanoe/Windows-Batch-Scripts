@ECHO OFF

set bkpfldr=\\nas\Backups
set bkpjob=C:\Scripts\server01.txt
set backup=C:\Scripts\tools\7za.exe

set smtpserver=mail.example.com
set emailfrom=admin@example.com
set emailto=admin@example.com
set emailprog=C:\Scripts\tools\blat.exe

REM ******************************************************************************************************************************
REM Since tape drives are absolete and NTBackup is gone in Windows Server 2008 R2 i started to use 7Zip as a backup way.
REM This script will create a backup zip to the destination folder  bkpfldr  and sources for the zip are in  the  bkpjob  file
REM After this is done, it will send a email and write to the eventlog
REM 
REM uses  BLAT   http://www.blat.net/
REM and 7-ZiP http://www.7-zip.org/   commandline version
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

REM DISK Backup
%backup% a -tzip "%bkpfldr%\%COMPUTERNAME%-%year%%month%%day%.zip" "@%bkpjob%" -v1g > %temp%\7za.log

REM Check NTBackup logs
for /F "tokens=3 delims=:" %%A in ('find /C "Error:" "%temp%\7za.log"') do set NR=%%A
if not "%NR%"==" 0" (
	eventcreate /L SYSTEM /T ERROR /ID 1 /SO "RE Backup" /D "DISK Backup harddrives. Computer: %computername% FAILED"
	%emailprog% -body "DISK Backup: %bkpfldr%\%COMPUTERNAME%-%year%%month%%day%.zip FAILED" -to %emailto% -f %emailfrom% -s "DISK Backup %COMPUTERNAME% FAILED" -attach "%temp%\7za.log" -server %smtpserver%
	exit
)
eventcreate /L SYSTEM /T SUCCESS /ID 1 /SO "RE Backup" /D "DISK Backup harddrives. Computer: %computername%"
%emailprog% -body "DISK Backup: %bkpfldr%\%COMPUTERNAME%-%year%%month%%day%.zip succesfull" -to %emailto% -f %emailfrom% -s "DISK Backup %COMPUTERNAME% SUCCESSFUL" -attach "%temp%\7za.log" -server %smtpserver%
del "%temp%\7za.log"

:end
exit