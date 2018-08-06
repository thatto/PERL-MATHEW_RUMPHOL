::  ============================================================================================================
::  TITLE:            BACKUP.CMD
::  VERSION:          1.4
::  CREATED:          02/05/2015
::  LAST UPDATE:      01/02/2016
::  AUTHOR:           MATHEW RUMPHOL
::  PREREQUISITES:    Requires XCOPY.EXE and NOW.exe
::  PURPOSE:          Copy personal data from Windows computer to drive letter of choice
::  ============================================================================================================

@ECHO OFF

SET COMMAND=BACKUP

IF "%1"=="/?" GOTO HELP
IF "%1"=="-?" GOTO HELP
IF "%1"=="" GOTO HELP
IF NOT "%1"=="" GOTO PATHCHECK


:PATHCHECK
:: [SET THE SOURCE FOLDERS TO COPY]
SET SOURCE1=D:\Documents\*.*
SET SOURCE2=D:\Pictures\*.*
SET SOURCE3=D:\Tools\*.*
SET SOURCE4=C:\Users\%username%\Favorites\*.*
SET SOURCE5=C:\Users\%username%\Desktop\*.*
SET SOURCE6=D:\Outlook Files\*.*

:: [SET THE DESTINATION TARGETS]
SET BACKUPFOLDER=2016 Backup
IF NOT EXIST "%1\%BACKUPFOLDER%" MD "%1\%BACKUPFOLDER%"

SET DESTINATION1="%1\%BACKUPFOLDER%\Documents\"
SET DESTINATION2="%1\%BACKUPFOLDER%\Pictures\"
SET DESTINATION3="%1\%BACKUPFOLDER%\Tools\"
SET DESTINATION4="%1\%BACKUPFOLDER%\Bookmarks\"
SET DESTINATION5="%1\%BACKUPFOLDER%\Desktop\"
SET DESTINATION6="%1\Outlook Files\"

:: [SETUP LOG FILE]
SET LOGFILE=Backup Log.txt
IF EXIST "%1\%BACKUPFOLDER%\%LOGFILE%" NOW >> "%1\%BACKUPFOLDER%\%LOGFILE%"
IF NOT EXIST "%1\%BACKUPFOLDER%\%LOGFILE%" NOW > "%1\%BACKUPFOLDER%\%LOGFILE%"
@ECHO -------------------------------------------------------------------------------------- >> "%1\%BACKUPFOLDER%\%LOGFILE%"
GOTO BEGIN

:BEGIN
CLS
@ECHO.
@ECHO Preparing to backup the following data to %1\%BACKUPFOLDER%:
@ECHO.
@ECHO %SOURCE1%
@ECHO %SOURCE2%
@ECHO %SOURCE3%
@ECHO %SOURCE4%
@ECHO %SOURCE5%
@ECHO %SOURCE6%
@ECHO.
@ECHO Press CTRL+C to Cancel or & PAUSE
GOTO STARTCOPY

:OVERWRITE
CLS
@ECHO.
IF EXIST "%1\%BACKUPFOLDER%" @ECHO The Folder "%1\%BACKUPFOLDER%" Already Exists... & @ECHO Do You Want To Continue? & @ECHO. & @ECHO Press CTRL+C to Cancel or & PAUSE
GOTO STARTCOPY

:STARTCOPY
@ECHO Backing up %SOURCE1% to %DESTINATION1%, Please wait...
@ECHO.
@ECHO.
@ECHO %SOURCE1% >> "%1\%BACKUPFOLDER%\%LOGFILE%"
@ECHO -------------------------------------------------------------------------------------- >> "%1\%BACKUPFOLDER%\%LOGFILE%"
XCOPY "%SOURCE1%" %DESTINATION1% /s /e /v /y /z /r /d >> "%1\%BACKUPFOLDER%\%LOGFILE%" 2>&1
@ECHO. >> "%1\%BACKUPFOLDER%\%LOGFILE%"

@ECHO Backing up %SOURCE2% to %DESTINATION2%, Please wait...
@ECHO.
@ECHO.
@ECHO %SOURCE2% >> "%1\%BACKUPFOLDER%\%LOGFILE%"
@ECHO -------------------------------------------------------------------------------------- >> "%1\%BACKUPFOLDER%\%LOGFILE%"
XCOPY "%SOURCE2%" %DESTINATION2% /s /e /v /y /z /r /d >> "%1\%BACKUPFOLDER%\%LOGFILE%" 2>&1
@ECHO. >> "%1\%BACKUPFOLDER%\%LOGFILE%"

@ECHO Backing up %SOURCE3% to %DESTINATION3%, Please wait...
@ECHO.
@ECHO.
@ECHO %SOURCE3% >> "%1\%BACKUPFOLDER%\%LOGFILE%"
@ECHO -------------------------------------------------------------------------------------- >> "%1\%BACKUPFOLDER%\%LOGFILE%"
XCOPY "%SOURCE3%" %DESTINATION3% /s /e /v /y /z /r /d >> "%1\%BACKUPFOLDER%\%LOGFILE%" 2>&1
@ECHO. >> "%1\%BACKUPFOLDER%\%LOGFILE%"

@ECHO Backing up %SOURCE4% to %DESTINATION4%, Please wait...
@ECHO.
@ECHO.
@ECHO %SOURCE4% >> "%1\%BACKUPFOLDER%\%LOGFILE%"
@ECHO -------------------------------------------------------------------------------------- >> "%1\%BACKUPFOLDER%\%LOGFILE%"
XCOPY "%SOURCE4%" %DESTINATION4% /s /e /v /y /z /r /d >> "%1\%BACKUPFOLDER%\%LOGFILE%" 2>&1
@ECHO. >> "%1\%BACKUPFOLDER%\%LOGFILE%"

@ECHO Backing up %SOURCE5% to %DESTINATION5%, Please wait...
@ECHO.
@ECHO.
@ECHO %SOURCE5% >> "%1\%BACKUPFOLDER%\%LOGFILE%"
@ECHO -------------------------------------------------------------------------------------- >> "%1\%BACKUPFOLDER%\%LOGFILE%"
XCOPY "%SOURCE5%" %DESTINATION5% /s /e /v /y /z /r /d >> "%1\%BACKUPFOLDER%\%LOGFILE%" 2>&1
@ECHO. >> "%1\%BACKUPFOLDER%\%LOGFILE%"

@ECHO Backing up %SOURCE6% to %DESTINATION6%, Please wait...
@ECHO.
@ECHO.
@ECHO %SOURCE6% >> "%1\%BACKUPFOLDER%\%LOGFILE%"
@ECHO -------------------------------------------------------------------------------------- >> "%1\%BACKUPFOLDER%\%LOGFILE%"
XCOPY "%SOURCE6%" %DESTINATION6% /s /e /v /y /z /r /d >> "%1\%BACKUPFOLDER%\%LOGFILE%" 2>&1
@ECHO. >> "%1\%BACKUPFOLDER%\%LOGFILE%"

GOTO FINISH

:HELP
@ECHO.
@ECHO.
@ECHO Usage: %COMMAND% [DRIVE LETTER:]
@ECHO.
@ECHO Example: %COMMAND% H:
@ECHO.
PAUSE
GOTO EOF

:FINISH
@ECHO.
@ECHO.
@ECHO.
@ECHO Backup of the Following Files Has Completed:
@ECHO.
@ECHO %SOURCE1%
@ECHO %SOURCE2%
@ECHO %SOURCE3%
@ECHO %SOURCE4%
@ECHO %SOURCE5%
@ECHO %SOURCE6%
@ECHO.
@ECHO.
PAUSE
CLS
@ECHO.

:EOF