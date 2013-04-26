@ECHO OFF

set magicpacket=C:\Scripts\tools\mc-wol.exe

REM ******************************************************************************************************************************
REM 00:1E:E5:29:F4:3D	RETM01	Machine		Compaq Pressario
REM 
REM This script uses Wake-on-LAN cmd utility
REM http://www.matcode.com/wol.htm
REM
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

REM Start Computers
%magicpacket% 00:0D:56:8F:45:43
%magicpacket% 00:0D:56:8F:45:5C

:end
exit