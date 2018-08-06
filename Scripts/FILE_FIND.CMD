:: ============================================================================================================
:: TITLE:         FILE_FIND.CMD
:: VERSION:       2.2
:: CREATED:       11/29/2011
:: LAST UPDATE:   02/13/2013
:: AUTHOR:        MATHEW RUMPHOL
:: PREREQUISITES: Populate EQUIPMENT.TXT with computer names
:: PURPOSE:       Check for files of choice against targets in EQUIPMENT.TXT
:: ============================================================================================================

@ECHO OFF

SET SOURCEFILE=..\INPUT\EQUIPMENT.TXT
SET REPORTNAME=..\REPORTS\"FILE_FIND REPORT.TXT"

SET COMMAND=FILECK
SET VERSION=Version 2.1
SET PURPOSE=Looks for file of choice on targets in %SOURCEFILE%

::[SYNTAX CHECK]

:SYNTAXCHK
:: Review the help section.
IF "%1"=="/?" GOTO HELP

:: Check for incomplete syntax.
IF "%1"=="" GOTO HELP

:: [BEGIN]

CLS
ECHO.
ECHO Ready to Search for %1
ECHO.
ECHO on the following targets:
ECHO.
TYPE %SOURCEFILE%
ECHO.
ECHO.
ECHO Press CTRL+C to cancel or & PAUSE
ECHO.
CLS
ECHO  ------------------------------------------------------------------------------ > %REPORTNAME%
ECHO. >> %REPORTNAME%

FOR /F "tokens=1" %%x in (%SOURCEFILE%) do ECHO Searching for %1 on %%x  Please wait... & ECHO \\%%x\%1 >> %REPORTNAME% & ECHO.>> %REPORTNAME% & DIR \\%%x\%1 >> %REPORTNAME% 2>&1 & ECHO  ------------------------------------------------------------------------------ >> %REPORTNAME% & ECHO. >> %REPORTNAME%
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
@ECHO  Command Syntax:   %COMMAND% [(PATH)]
@ECHO.
@ECHO   Example: %COMMAND% C$\TEMP\*.Log
@ECHO  __________________________________________________________
@ECHO.
GOTO EOF

:EOF