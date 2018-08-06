::  ============================================================================================================
::  TITLE:            BACKUP_DATA.CMD
::  VERSION:          1.1
::  CREATED:          02/07/2013
::  LAST UPDATE:      01/09/2014
::  AUTHOR:           MATHEW RUMPHOL
::  PREREQUISITES:    Requires XCOPY.EXE
::  PURPOSE:          Copy personal data from Windows computer to drive letter of choice
::  ============================================================================================================

@ECHO OFF

SET COMMAND=BACKUP_DATA

IF "%1"=="/?" GOTO HELP
IF "%1"=="-?" GOTO HELP
IF "%1"=="" GOTO HELP
IF NOT "%1"=="" GOTO PATHCHECK

:PATHCHECK
:: [WINDOWS 5X DATA PATHS]
SET FOLDER1="C:\Documents and Settings\%username%\My Documents\*.*"
SET FOLDER2="C:\Documents and Settings\%username%\Favorites\*.*"
SET FOLDER3="C:\Documents and Settings\%username%\My Pictures\*.*"
SET FOLDER4="C:\Documents and Settings\%username%\Desktop\*.*"

:: [WINDOWS 6X DATA PATHS]
SET FOLDER5="C:\Users\%username%\Documents\*.*"
SET FOLDER6="C:\Users\%username%\Favorites\*.*"
SET FOLDER7="C:\Users\%username%\Pictures\*.*"
SET FOLDER8="C:\Users\%username%\Desktop\*.*"

:: [GENERIC DATA PATHS]
SET FOLDER9="C:\Tools\*.*"
SET FOLDER10="D:\Tools\*.*"

:: [DETERMINE WHAT TO BACKUP]
IF EXIST %FOLDER1% SET SOURCE1=%FOLDER1%
IF EXIST %FOLDER2% SET SOURCE2=%FOLDER2%
IF EXIST %FOLDER3% SET SOURCE3=%FOLDER3%
IF EXIST %FOLDER4% SET SOURCE4=%FOLDER4%
IF EXIST %FOLDER5% SET SOURCE1=%FOLDER5%
IF EXIST %FOLDER6% SET SOURCE2=%FOLDER6%
IF EXIST %FOLDER7% SET SOURCE3=%FOLDER7%
IF EXIST %FOLDER8% SET SOURCE4=%FOLDER8%
IF EXIST %FOLDER9% SET SOURCE5=%FOLDER9%
IF EXIST %FOLDER10% SET SOURCE5=%FOLDER10%

:: [SET THE DESTINATION TARGETS]
SET BACKUPFOLDER=2014 Backup
SET DESTINATION1="%1\%BACKUPFOLDER%\DOCUMENTS\"
SET DESTINATION2="%1\%BACKUPFOLDER%\BOOKMARKS\"
SET DESTINATION3="%1\%BACKUPFOLDER%\PICTURES\"
SET DESTINATION4="%1\%BACKUPFOLDER%\DESKTOP\"
SET DESTINATION5="%1\%BACKUPFOLDER%\TOOLS\"

GOTO BEGIN

:BEGIN
CLS
@ECHO.
@ECHO Preparing to backup the following data:
@ECHO.
@ECHO %SOURCE1%
@ECHO %SOURCE2%
@ECHO %SOURCE3%
@ECHO %SOURCE4%
@ECHO %SOURCE5%
@ECHO.
@ECHO Press CTRL+C to Cancel or & PAUSE
GOTO OVERWRITE

:OVERWRITE
CLS
@ECHO.
IF EXIST "%1\%BACKUPFOLDER%" @ECHO The Folder "%1\%BACKUPFOLDER%" Already Exists... & @ECHO Do You Want To Continue? & @ECHO. & @ECHO Press CTRL+C to Cancel or & PAUSE
GOTO STARTCOPY

:STARTCOPY
::CLS
START XCOPY %SOURCE1% %DESTINATION1% /s /e /v /y /z /r /d
START XCOPY %SOURCE2% %DESTINATION2% /s /e /v /y /z /r /d
START XCOPY %SOURCE3% %DESTINATION3% /s /e /v /y /z /r /d
START XCOPY %SOURCE4% %DESTINATION4% /s /e /v /y /z /r /d
START XCOPY %SOURCE5% %DESTINATION5% /s /e /v /y /z /r /d
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
@ECHO Backup of Files Has Been Started...
@ECHO.
@ECHO Please Wait For All Backup Windows To Close
@ECHO.
PAUSE
CLS
@ECHO.

:EOF