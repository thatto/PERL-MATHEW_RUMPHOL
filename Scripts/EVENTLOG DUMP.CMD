::  ============================================================================================================
::  TITLE:            EVENTLOG DUMP.CMD
::  VERSION:          1.1
::  CREATED:          10/16/2009
::  LAST UPDATE:      02/15/2011
::  AUTHOR:           MATHEW RUMPHOL
::  PREREQUISITES:    Requires DUMPEL.EXE. Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
::  PURPOSE:          Captures EVENT LOG information from the Windows Event Log for each
::                    computer listed in PINGABLE.TXT
::  ============================================================================================================
@ECHO OFF

SET SOURCEFILE=..\INPUT\PINGABLE.TXT
SET OUTPUTFILE=..\REPORTS\%%x_EL_REPORT.TXT
SET REPORTFILE=..\REPORTS\EVENTLOG_REPORT.TXT
SET COMMAND=EVENTLOG_DUMP
SET VERSION=Version 1.0
SET PURPOSE=Queries Windows Event Log Remotely


:: _________________________________________________________________
::
::                          SYNTAX CHECK
:: _________________________________________________________________

:SYNTAXCHK
:: Review the help section.
IF "%1"=="/?" GOTO HELP

:: Check for incomplete syntax.
IF "%1"=="" GOTO HELP
IF "%2"=="" GOTO HELP
IF "%3"=="" GOTO HELP
IF "%4"=="" GOTO HELP


:: _________________________________________________________________
::
::                          BEGIN QUERY
:: _________________________________________________________________

ECHO Date	Time	Type	Category	Event ID	Source	Account	Computer	Description > %REPORTFILE%
FOR /F "tokens=1" %%x in (%SOURCEFILE%) DO @ECHO. & @ECHO Capturing EventLog Data on %%x & DUMPEL -s \\%%x -l %1 -m %2 -e %3 -d %4 -f %OUTPUTFILE% & TYPE %OUTPUTFILE% >> %REPORTFILE%
DEL ..\REPORTS\*_EL_REPORT.TXT
@ECHO. & @ECHO Report Created: %REPORTFILE%
GOTO EOF


:: _________________________________________________________________
::
::                          HELP SECTION
:: _________________________________________________________________

:HELP
@ECHO.
@ECHO.
@ECHO  %COMMAND%, %VERSION%
@ECHO.
@ECHO  %PURPOSE%
@ECHO.
@ECHO  __________________________________________________________
@ECHO.
@ECHO  Command Help:     %COMMAND% /?
@ECHO.
@ECHO  Command Syntax:   %COMMAND% [LOG] [SOURCE] [EVENT ID] [PRIOR DAYS]
@ECHO.
@ECHO   Example: %COMMAND% System EventLog 6006 1
@ECHO  __________________________________________________________
@ECHO.
GOTO EOF

:EOF