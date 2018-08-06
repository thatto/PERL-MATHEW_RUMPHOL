::  ============================================================================================================
::  TITLE:            PATCH SCAN.CMD
::  VERSION:          4.1
::  CREATED:          01/14/2009
::  LAST UPDATE:      11/04/2011
::  AUTHOR:           MATHEW RUMPHOL
::  PREREQUISITES:    Requires DUMPEL.EXE. Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
::  PURPOSE:          Captures NT SERVICE PACK (HOTFIX) information from the Windows Event Log for each
::                    computer listed in PINGABLE.TXT
::  ============================================================================================================
@ECHO OFF

SET SOURCEFILE=..\INPUT\PINGABLE.TXT
SET TMPFILE= ..\REPORTS\PATCH_DATA.TMP
SET OUTPUTFILE=..\REPORTS\PATCH_SCAN_REPORT.TXT

@ECHO.

IF EXIST %TMPFILE% DEL %TMPFILE%
@ECHO.
@ECHO Collecting Installed Patch Information. Please wait...
@ECHO.


:: [Windows 2000, Windows 2003 & Windows XP]
:WIN5X
@ECHO DATE	TIME	TYPE	CATEGORY	EVENT ID	SOURCE	USER		COMPUTER	DESCRIPTION> %OUTPUTFILE%
FOR /F "tokens=1" %%x in (%SOURCEFILE%) DO IF EXIST "\\%%x\C$\Documents and Settings" DUMPEL -s \\%%x -l system -m NtServicePack -f %TMPFILE% & TYPE %TMPFILE%>> %OUTPUTFILE%
:: DEL %TMPFILE%
:: GOTO EOF

:: [Windows 2008, Windows Vista & Windows 7]
:WIN6X
@ECHO DATE	TIME	TYPE	CATEGORY	EVENT ID	SOURCE	USER		COMPUTER	DESCRIPTION> %OUTPUTFILE%
FOR /F "tokens=1" %%x in (%SOURCEFILE%) DO IF EXIST "\\%%x\C$\Users" DUMPEL -s \\%%x -l system -m Microsoft-Windows-WindowsUpdateClient -e 19 -f %TMPFILE% & TYPE %TMPFILE%>> %OUTPUTFILE%
DEL %TMPFILE%
GOTO EOF

:EOF