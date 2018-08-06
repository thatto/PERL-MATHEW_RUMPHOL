:: ============================================================================================================
:: TITLE:         PROFILES.CMD
:: VERSION:       1.0
:: CREATED:       10/11/2010
:: LAST UPDATE:   10/11/2010
:: AUTHOR:        MATHEW RUMPHOL
:: PREREQUISITES: Populate EQUIPMENT.TXT with computer names and run PINGIT.PL
:: PURPOSE:       Lists profiles on target systems
:: ============================================================================================================
@ECHO OFF

SET SOURCEFILE=..\INPUT\PINGABLE.TXT
SET OUTPUTFILE=..\REPORTS\PROFILES.TXT

@ECHO.

@ECHO. > %OUTPUTFILE%
FOR /F "tokens=1" %%x in (%SOURCEFILE%) DO @ECHO  %%x & DIR "\\%%x\c$\Documents and Settings" >> %OUTPUTFILE%