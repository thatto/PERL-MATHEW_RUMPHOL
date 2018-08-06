' ***********************************************************************************************************************
' TITLE:			CLIENTDATA SIZES.VBS
' VERSION:			1.1
' CREATED:			03/07/2013
' LAST UPDATE:		03/12/2013
' AUTHOR:			MATHEW RUMPHOL
' PREREQUISITES:	
' PURPOSE:			Point in time capture of DIRECTORY TREE, FILE COUNT and FOLDER SIZES
' ***********************************************************************************************************************

' [SET THE DESIRED DELIMITER FOR REPORTING]
Delimiter = chr(44) 'Comma character

' [SET THE OUTPUT FILE PATH & NAME]
set objFSO = CreateObject("Scripting.FileSystemObject")
set objFile = objFSO.CreateTextFile("CLIENTDATA.CSV", True)

' [SET THE FOLDER STRUCTURE TO BE DISCOVERED]
dim oFS, oFolder
set oFS = WScript.CreateObject("Scripting.FileSystemObject")
set oFolder = oFS.GetFolder("\\BBHCIFS01\CLIENTDATA\")
'set oFolder = oFS.GetFolder("D:\Tools")


' [WRITE THE COLUMN HEADERS TO THE OUTPUT FILE]
objFile.WriteLine "Date"  & Delimiter & "Folder" & Delimiter & "Files" & Delimiter & "Size (bytes)"

' [RUN THE SUBROUTINE TO CAPTURE THE FOLDER DATA]
ShowFolderDetails oFolder

sub ShowFolderDetails(oF)
dim F
dim dtmDateStamp
	dtmDateStamp = Now
	objFile.WriteLine dtmDateStamp & Delimiter & oF.Path & Delimiter & oF.Files.Count & Delimiter & oF.Size
	for each F in oF.Subfolders
	ShowFolderDetails(F)
	next
end sub