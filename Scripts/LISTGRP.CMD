::  ============================================================================================================
::  TITLE:            LISTGRP.CMD
::  VERSION:          6.1
::  CREATED:          01/13/2009
::  LAST UPDATE:      05/20/2011
::  AUTHOR:           MATHEW RUMPHOL
::  PREREQUISITES:    This script calls LISTMEMBERS.VBS, FIND.EXE and SED.EXE
::  PURPOSE:          Query computers for Windows group membership
::  ============================================================================================================
@ECHO OFF
CLS

:: [VARIABLES]

SET COMMAND=LISTGRP
SET VERSION=Version 4.0
SET PURPOSE=Queries Windows Group Membership

SET TMPFILE1=1.tmp
SET TMPFILE2=2.tmp

SET REPORT=..\REPORTS\GROUP_MEMBERSHIP.TXT
SET LIST=..\INPUT\EQUIPMENT.TXT
SET OBJECT=group

:: [SYNTAX CHECK]

:: Check for spaces in the group name
IF NOT "%9"=="" GOTO 8SPACES
IF NOT "%8"=="" GOTO 7SPACES
IF NOT "%7"=="" GOTO 6SPACES
IF NOT "%6"=="" GOTO 5SPACES
IF NOT "%5"=="" GOTO 4SPACES
IF NOT "%4"=="" GOTO 3SPACES
IF NOT "%3"=="" GOTO 2SPACES

SET ARG2=%2
GOTO PRECLEAN


:8SPACES
SET ARG2=%2 %3 %4 %5 %6 %7 %8 %9
GOTO PRECLEAN

:7SPACES
SET ARG2=%2 %3 %4 %5 %6 %7 %8
GOTO PRECLEAN

:6SPACES
SET ARG2=%2 %3 %4 %5 %6 %7
GOTO PRECLEAN

:5SPACES
SET ARG2=%2 %3 %4 %5 %6
GOTO PRECLEAN

:4SPACES
SET ARG2=%2 %3 %4 %5
GOTO PRECLEAN

:3SPACES
SET ARG2=%2 %3 %4
GOTO PRECLEAN

:2SPACES
SET ARG2=%2 %3
GOTO PRECLEAN


:PRECLEAN
@ECHO Checking %ARG2% membership....
:: Cleanup files that may still exist
IF EXIST %TMPFILE1% DEL %TMPFILE1%
IF EXIST %TMPFILE2% DEL %TMPFILE2%
IF EXIST %REPORT% DEL %REPORT%

:: [MORE SYNTAX CHECKING]

:SYNTAXCHK
:: Review the help section.
IF "%1"=="/?" GOTO HELP

:: Check for incomplete syntax.
IF "%1"=="" GOTO HELP

:: Check for backslashes in the syntax.
@ECHO %1 >%1.TMP 2>&1
IF NOT EXIST %1.TMP GOTO BADNAME
DEL %1.TMP

:: Check for command usage (single query vs. list)
IF "%1"=="all" GOTO SOURCELIST
IF "%1"=="ALL" GOTO SOURCELIST
GOTO SINGLEQUERY

:: [HELP SECTION]

:HELP
@ECHO.
@ECHO  %COMMAND%, %VERSION%
@ECHO  %AUTHOR%, %COMPANY%, %PUBDATE%
@ECHO.
@ECHO  %PURPOSE%
@ECHO.
@ECHO.
@ECHO  %COMMAND% /?     Command usage
@ECHO.
@ECHO.
@ECHO  %COMMAND% [COMPUTER or DOMAIN] [%OBJECT%]
@ECHO.
@ECHO    Example: %COMMAND% COMPUTER "Power Users"
@ECHO.
@ECHO    Queries a specified %OBJECT% on the target computer or domain.
@ECHO.
@ECHO    Note: %OBJECT% names with spaces must be enclosed in "quote marks"
@ECHO.
@ECHO             ***** BACKSLASHES ARE NOT ALLOWED *****
@ECHO.
@ECHO.
@ECHO  %COMMAND% [ALL] [%OBJECT%]
@ECHO.
@ECHO    Example: %COMMAND% ALL Administrators
@ECHO.
@ECHO    For use with a text file list (%LIST%) of computers or domains.
@ECHO    Queries a specified %OBJECT% on all computers or domains
@ECHO    listed in %LIST%.
@ECHO.
@ECHO    Creates a report (%REPORT%) from the queried data.
@ECHO.
GOTO EOF

:: [LIST CHECKING]

:SOURCELIST
If not exist %LIST% GOTO NOLIST
GOTO LISTQUERY


:: [BEGIN QUERY]

:LISTQUERY
IF "%ARG2%"=="" GOTO NOGROUP
@ECHO.
FOR /f %%i in (%LIST%) do ECHO Querying %ARG2% %OBJECT% on... %%i & cscript listmembers.vbs WinNT://%%i/%ARG2% >>%TMPFILE1%
:: GOTO EOF

:SINGLEQUERY
IF "%ARG2%"=="" GOTO NOGROUP
cscript listmembers.vbs WinNT://%1/"%ARG2%" >>%TMPFILE1%

:: Clean up the data
FIND /i /v "Windows Script Host Version" < %TMPFILE1% >%TMPFILE2%
FIND /i /v "Getting" < %TMPFILE2% >%TMPFILE1%
FIND /i /v "Copyright" < %TMPFILE1% >%TMPFILE2%
FIND /i /v "object" < %TMPFILE2% >%TMPFILE1%
::SED -e "s/\/\///" < %TMPFILE1% >%TMPFILE2%
::SED -e "s/\//\\/" < %TMPFILE2% >%TMPFILE1%
::SED -e "s/WinNT://" < %TMPFILE1% >%TMPFILE2%

:: Create the report
CLS
IF EXIST %REPORT% DEL %REPORT%
TYPE %TMPFILE2% >>%REPORT%
DEL %TMPFILE1%
DEL %TMPFILE2%
GOTO EOF

:: [ERROR MESSAGES]

:NOLIST
CLS
@ECHO.
@ECHO.
@ECHO %LIST% could not be found.... See help for more information.
PAUSE

:BADNAME
CLS
@ECHO.
@ECHO Backslashes are not allowed.
@ECHO.
@ECHO.
PAUSE
GOTO HELP

:NOGROUP
@ECHO.
@ECHO You did not specify a %OBJECT%...
@ECHO.
@ECHO.
PAUSE
GOTO HELP

:EOF
IF EXIST %REPORT% TYPE %REPORT%