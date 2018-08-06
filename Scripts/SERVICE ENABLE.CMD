:: ============================================================================================================
:: TITLE:         SERVICE ENABLE.CMD
:: VERSION:       2.1
:: CREATED:       01/23/2009
:: LAST UPDATE:   02/07/2013
:: AUTHOR:        MATHEW RUMPHOL
:: PREREQUISITES: Requires SC.EXE. Populate EQUIPMENT.TXT with computer names and run PINGIT.PL
:: PURPOSE:       Sets service of choice to AUTOMATIC on computers in target list
:: ============================================================================================================

@ECHO OFF

SET SOURCEFILE=..\INPUT\PINGABLE.TXT
SET REPORTNAME=..\REPORTS\DISABLE SERVICE REPORT.TXT

SET COMMAND=ENABLE_SERVICE
SET VERSION=Version 2.0
SET PREREQUISITE=Note: Requires SC.EXE
SET PURPOSE=Disables Windows service of choice for computers in %SOURCEFILE%

:: =================================================================
::                          SYNTAX CHECK
:: =================================================================

:SYNTAXCHK
:: Review the help section.
IF "%1"=="/?" GOTO HELP

:: Check for incomplete syntax.
IF "%1"=="" GOTO HELP

:: =================================================================
::                            BEGIN
:: =================================================================

CLS
ECHO.
ECHO Ready to enable %1 service
ECHO.
ECHO on the following targets:
ECHO.
TYPE %SOURCEFILE%
ECHO.
ECHO.
ECHO Press CTRL+C to cancel or & PAUSE
ECHO.
CLS
ECHO ------------------------------------------------------------------------------------------------- > %REPORTNAME%
ECHO. >> %REPORTNAME%

FOR /F "tokens=1" %%x in (%SOURCEFILE%) DO ECHO Enabling %1 service on %%x & ECHO. & sc \\%%x config %1 start= auto

GOTO EOF

:: =================================================================
::                          HELP SECTION
:: =================================================================

:HELP
@ECHO.
@ECHO.
@ECHO  %COMMAND%, %VERSION%
@ECHO.
@ECHO  %PURPOSE%
@ECHO.
@ECHO  %PREREQUISITE%
@ECHO.
@ECHO  __________________________________________________________
@ECHO.
@ECHO   Command Help:     %COMMAND% /?
@ECHO.
@ECHO   Command Syntax:   %COMMAND% [SERVICE]
@ECHO.
@ECHO   Example: %COMMAND% ALERTER
@ECHO  __________________________________________________________
@ECHO.
GOTO EOF

:EOF