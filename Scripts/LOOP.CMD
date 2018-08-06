:: ============================================================================================================
:: TITLE:         LOOP.CMD
:: VERSION:       2.1
:: CREATED:       12/04/2009
:: LAST UPDATE:   01/09/2012
:: AUTHOR:        MATHEW RUMPHOL
:: PREREQUISITES: Populate EQUIPMENT.TXT with computer names
:: PURPOSE:       Runs command of choice against targets in EQUIPMENT.TXT
:: ============================================================================================================

@ECHO OFF

SET COMMAND=LOOP
SET VERSION=Version 2.1
SET PURPOSE=Runs command of choice against targets in %SOURCEFILE%

::[SYNTAX CHECK]

:SYNTAXCHK
:: Review the help section.
IF "%1"=="/?" GOTO HELP

:: Check for incomplete syntax.
IF "%1"=="" GOTO HELP

:: [BEGIN]
SET SOURCEFILE=..\INPUT\EQUIPMENT.TXT
SET REPORTNAME=..\REPORTS\%1_REPORT.TXT

CLS
ECHO.
ECHO Ready to run %1 %2
ECHO.
ECHO Against the following targets:
ECHO.
TYPE %SOURCEFILE%
ECHO.
ECHO.
ECHO Press CTRL+C to cancel or & PAUSE
ECHO.
CLS
ECHO  ------------------------------------------------------------------------------ > %REPORTNAME%
ECHO. >> %REPORTNAME%

FOR /F "tokens=1" %%x in (%SOURCEFILE%) do ECHO Running %1 %2 against %%x  Please wait... & ECHO %1 %2 %%x >> %REPORTNAME% & ECHO.>> %REPORTNAME% & %1 %2 %%x >> %REPORTNAME% 2>&1 & ECHO  ------------------------------------------------------------------------------ >> %REPORTNAME% & ECHO. >> %REPORTNAME%
CLS
TYPE %REPORTNAME%
GOTO EOF

:: [HELP SECTION]


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
@ECHO  Command Syntax:   %COMMAND% [(COMMAND)]
@ECHO.
@ECHO   Example: %COMMAND% NSLOOKUP
@ECHO  __________________________________________________________
@ECHO.
GOTO EOF

:EOF