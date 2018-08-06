:: ============================================================================================================
:: TITLE:         FILE_COPY.CMD
:: VERSION:       1.2
:: CREATED:       11/04/2009
:: LAST UPDATE:   02/13/2013
:: AUTHOR:        MATHEW RUMPHOL
:: PREREQUISITES: Requires XCOPY.EXE. Populate EQUIPMENT.TXT with computer names and run PINGIT.PL
:: PURPOSE:       Copies a file or files to targets
:: ============================================================================================================

@ECHO OFF

SET SOURCEFILE=..\INPUT\PINGABLE.TXT
SET SOURCE=%1
SET TARGET=%2

SET COMMAND=FILECOPY
SET VERSION=Version 1.2
SET PURPOSE=Copies a file or files to targets in %SOURCEFILE%


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


:: _________________________________________________________________
::
::                          BEGIN COPY
:: _________________________________________________________________
ECHO.
ECHO Preparing to copy: %SOURCE%
ECHO.
ECHO To: %TARGET%
ECHO.
ECHO On the following target computers:
ECHO.
TYPE %SOURCEFILE%
ECHO.
ECHO Press CTRL+C to cancel or & PAUSE
ECHO.


FOR /F "tokens=1" %%x in (%SOURCEFILE%) do ECHO. & ECHO Copying file(s) to %%x\%TARGET% & ECHO. & XCOPY "%SOURCE%" "\\%%x\%TARGET%"

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
@ECHO  Command Syntax:   %COMMAND% [SOURCE FILE(S)] [TARGET LOCATION]
@ECHO.
@ECHO   Example: %COMMAND% C:\TEMP\TEST.TXT C$\TOOLS\
@ECHO  __________________________________________________________
@ECHO.
GOTO EOF

:EOF