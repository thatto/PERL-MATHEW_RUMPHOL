::  ============================================================================================================
::  TITLE:            DATA SYNC.CMD
::  VERSION:          1.0
::  CREATED:          11/20/2013
::  LAST UPDATE:      11/20/2013
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
SET FOLDER1="C:\Documents and Settings\%username%\My Documents\"
SET FOLDER2="C:\Documents and Settings\%username%\Favorites\"
SET FOLDER3="C:\Documents and Settings\%username%\My Pictures\"
SET FOLDER4="C:\Documents and Settings\%username%\Desktop\"

:: [WINDOWS 6X DATA PATHS]
SET FOLDER5="C:\Users\%username%\Documents\"
SET FOLDER6="C:\Users\%username%\Favorites\"
SET FOLDER7="C:\Users\%username%\Pictures\"
SET FOLDER8="C:\Users\%username%\Desktop\"

:: [GENERIC DATA PATHS]
SET FOLDER9="C:\Tools\"
SET FOLDER10="D:\Tools\"

:: [DETERMINE WHAT TO BACKUP]
IF EXIST %FOLDER1% SET DESTINATION1=%FOLDER1%
IF EXIST %FOLDER2% SET DESTINATION2=%FOLDER2%
IF EXIST %FOLDER3% SET DESTINATION3=%FOLDER3%
IF EXIST %FOLDER4% SET DESTINATION4=%FOLDER4%
IF EXIST %FOLDER5% SET DESTINATION1=%FOLDER5%
IF EXIST %FOLDER6% SET DESTINATION2=%FOLDER6%
IF EXIST %FOLDER7% SET DESTINATION3=%FOLDER7%
IF EXIST %FOLDER8% SET DESTINATION4=%FOLDER8%
IF EXIST %FOLDER9% SET DESTINATION5=%FOLDER9%
IF EXIST %FOLDER10% SET DESTINATION5=%FOLDER10%

:: [SET THE DESTINATION TARGETS]
SET SOURCE1="%1\2014 Backup\DOCUMENTS\*.*"
SET SOURCE2="%1\2014 Backup\BOOKMARKS\*.*"
SET SOURCE3="%1\2014 Backup\PICTURES\*.*"
SET SOURCE4="%1\2014 Backup\DESKTOP\*.*"
SET SOURCE5="%1\2014 Backup\TOOLS\*.*"

GOTO BEGIN

:BEGIN
CLS
@ECHO.
@ECHO Preparing to sync the following data:
@ECHO.
@ECHO %SOURCE1% to %DESTINATION1%
@ECHO %SOURCE2% to %DESTINATION2%
@ECHO %SOURCE3% to %DESTINATION3%
@ECHO %SOURCE4% to %DESTINATION4%
@ECHO %SOURCE5% to %DESTINATION5%
@ECHO.
@ECHO Press CTRL+C to Cancel or & PAUSE
GOTO STARTCOPY


:STARTCOPY
CLS
XCOPY %SOURCE1% %DESTINATION1% /s /e /v /y /z /r /d
XCOPY %SOURCE2% %DESTINATION2% /s /e /v /y /z /r /d
XCOPY %SOURCE3% %DESTINATION3% /s /e /v /y /z /r /d
XCOPY %SOURCE4% %DESTINATION4% /s /e /v /y /z /r /d
XCOPY %SOURCE5% %DESTINATION5% /s /e /v /y /z /r /d

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
@ECHO Sync of Files Has Been Started...
@ECHO.
@ECHO Please Wait For All Windows To Close
@ECHO.
PAUSE
::CLS
@ECHO.

:EOF