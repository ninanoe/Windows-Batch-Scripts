@ECHO OFF

set ntbackupfldr=C:\Documents and Settings\Administrator\Local Settings\Application Data\Microsoft\Windows NT\NTBackup\data
set bkpjob=c:\scripts\server01.bks

set backup=ntbackup.exe
set rsm=rsm.exe

set smtpserver=mail.example.com
set emailfrom=admin@example.com
set emailto=admin@example.com
set emailprog=C:\Scripts\tools\blat.exe

REM ******************************************************************************************************************************
REM NTBackup script made for Windows 2003 R2 server for backups.   Many admins fail to understand the power of NTBackup.
REM Script wil run each day and do a (LTO) tape backup that you can set true the varables above.
REM After the backup it wil eject the tape and send you an email and write to the eventlog.
REM
REM Uses BLAT as the commandline email tool. http://www.blat.net/
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

REM Delete NTBackup logs
del "%ntbackupfldr%\*.log"

REM TAPE Backup
%backup% backup "@%bkpjob%" /n "%computername%-%year%-%month%-%day%" /d "daily tape %year%-%month%-%day%" /v:no /r:no /rs:no /hc:on /m normal /j "TAPE Backup %day%-%month%-%year%" /l:s /p "LTO Ultrium" /UM
%rsm% eject /pf"%computername%-%year%-%month%-%day% - 1" /astart

REM Pauze 60 sec voor logs tijd te geven
ping -n 60 127.0.0.1>nul

REM Check NTBackup logs
for /F "tokens=3 delims=:" %%A in ('find /C "The operation" "%ntbackupfldr%\*.log"') do set NR=%%A
if not "%NR%"==" 0" (
	eventcreate /L SYSTEM /T ERROR /ID 1 /SO "RE Backup" /D "Backup VMWare. Computer: %computername% FAILED"
	%emailprog% -body "TAPE Backup: %COMPUTERNAME%-%year%%month%%day%.LTO Tape FAILED" -to %emailto% -f %emailfrom% -s "TAPE Backup %COMPUTERNAME% FAILED" -attach "%ntbackupfldr%\*.log" -server %smtpserver%
	exit
)
eventcreate /L SYSTEM /T SUCCESS /ID 1 /SO "RE Backup" /D "TAPE Backup harddrives. Computer: %computername%"
%emailprog% -body "TAPE Backup: %COMPUTERNAME%-%year%%month%%day%.LTO Tape succesfull" -to %emailto% -f %emailfrom% -s "TAPE Backup %COMPUTERNAME% SUCCESSFUL" -attach "%ntbackupfldr%\*.log" -server %smtpserver%

:end
exit