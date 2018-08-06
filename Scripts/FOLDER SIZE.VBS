'==========================================================================
' NAME: folderSize.vbs
' COMMENT: Scans folder sizes of a selected folder.
'==========================================================================
Dim objFSO, objFolder, objFile, objFile2, F, myVar1, myVar2, folderCount, strWrite

folderCount = 0
objFile2 = "folderdetails.csv"

Set objFSO = WScript.CreateObject("Scripting.FileSystemObject")
Call browseFolder(strFolderSrc,"Source")
Set objFolder = objFSO.GetFolder(strFolderSrc)

'Write Header Row
Set objFile = CreateObject("Scripting.FileSystemObject")   
Set strWrite = objFile.OpenTextFile(objFile2, 2, True)
strWrite.WriteLine("Folder Name,Size (MB),# Files,# Sub Folders")
Wscript.Sleep 300

ShowFolderDetails objFolder

strWrite.Close

MsgBox "Complete."

Set objFSO = Nothing
Set objFolder = Nothing
Set objFile = Nothing
Set objFile2 = Nothing
Set F = Nothing
Set myVar1 = Nothing
Set myVar2 = Nothing
Set strWrite = Nothing

WScript.Quit
  
'==========================================================================
'Functions
Function ShowFolderDetails(oF)
    strWrite.WriteLine(oF.Name + "," + CStr(oF.Size /1024\1024) + "," + CStr(oF.Files.Count) + "," + CStr(oF.Subfolders.Count))

    'Comment out the following line and the loop to end the statement
    'to list all subfolders.(End Loop is 6 lines down)
    Do While folderCount < 1
    	for each F in oF.Subfolders
        	ShowFolderDetails F
    	Next
    	folderCount = folderCount + 1
    Loop
End Function

' browseFolder brings up the selection box to choose both the source and the destination.
Function browseFolder(myVar1,myVar2)
	Const WINDOW_HANDLE = 0
	Const NO_OPTIONS = 0
	Set objShell = CreateObject("Shell.Application")
	Set objFolder = objShell.BrowseForFolder _
    	(WINDOW_HANDLE, "Select a " & myVar2 & " folder:", NO_OPTIONS, "C:\Scripts")
	On Error Resume Next
	Set objFolderItem = objFolder.Self
	objPath = objFolderItem.Path
	myVar1 = objPath
	Call objPathChk(myVar1)
End Function

' objPathChk checks to make sure that a source has been selected.
Function objPathChk(myVar1)
	If myVar1 = "" Then
		MsgBox "Scan Folder Not Specified." & VbCrLf & _
				"Scan will now quit.", vbOKOnly, "Terminate"
		WScript.Quit
	End If		
End Function
'==========================================================================