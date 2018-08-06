' ***********************************************************************************************************************
' TITLE:			FOLDER SIZES.VBS
' VERSION:			1.0
' CREATED:			03/07/2013
' LAST UPDATE:	03/07/2013
' AUTHOR:			MATHEW RUMPHOL
' PREREQUISITES:	
' PURPOSE:			Capture DIRECTORY TREE, SUBFOLDER COUNT, FILE COUNT and FOLDER SIZES
' ***********************************************************************************************************************
TAB = chr(9)

Dim oShell
Set oShell = CreateObject("Wscript.Shell")

forceUseCScript

Sub forceUseCScript()
	If Not WScript.FullName = WScript.Path & "\cscript.exe" Then
		oShell.Run "cmd.exe /k " & WScript.Path & "\cscript.exe  " & Chr(34) & WScript.scriptFullName & Chr(34),1,False
		WScript.Quit 0
	End If
End Sub



strFolderPath = trim(InputBox("Please enter folder path:", "Folder Sizes", "D:\Tools\"))
if strFolderPath = "" then
	Wscript.Quit 1
end if

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.CreateTextFile("..\REPORTS\FOLDER SIZES REPORT.TXT", True)

dim oFS, oFolder
set oFS = WScript.CreateObject("Scripting.FileSystemObject")
set oFolder = oFS.GetFolder(strFolderPath)

objFile.WriteLine "Date"  & TAB & "Folder" & TAB & "Subfolders" & TAB & "Files" & TAB & "Size (bytes)"

ShowFolderDetails oFolder

sub ShowFolderDetails(oF)
dim F
dim dtmDate
dtmDate = Now

	wscript.echo oF.Path 
	objFile.WriteLine dtmDate & dtmTime & TAB & oF.Path & TAB & oF.Subfolders.count & TAB & oF.Files.Count & TAB & oF.Size
	for each F in oF.Subfolders
	ShowFolderDetails(F)
	next
end sub