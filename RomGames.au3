#AutoIt3Wrapper_UseX64=Y ;(Y/N) Use AutoIt3_x64 or Aut2Exe_x64. Default=N
#include <Array.au3>
#include <SQLite.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>

; ---------------------------
; ---------- Start ----------
; ---------------------------
Local $sDatFolder    = @ScriptDir & '\DatFiles'
Local $sDBFile 	     = @ScriptDir & '\SQLiteTestDatabase.db'
Local $hDB  	     = ''
Local $debug 	     = False  ; turn on debugging
Local $iDbKey 	     = 0
Local $iDbValue      = 1
Local $iDbDelLeft    = 2
Local $iDbDelRight   = 3
; initialize DB keys
Local $aDBKeyValue[0][6]
; column titles
;$aDBKeyValue[0][$iDbKey] 	   = 'key'
;$aDBKeyValue[0][$iDbValue]    = 'value'
;$aDBKeyValue[0][$iDbDelLeft]  = 'delimiter_left'
;$aDBKeyValue[0][$iDbDelRight] = 'delimiter_right'
; ---- game data - key/value
Local $iDBGameDataStart = 0
_ArrayAdd($aDBKeyValue, 'game_name||<game name="|(')
Local $iGame_name = 0
_ArrayAdd($aDBKeyValue, 'date|||')
Local $iDate = 1
_ArrayAdd($aDBKeyValue, 'publisher|||')
Local $iPublisher = 2
_ArrayAdd($aDBKeyValue, 'region||region="|"')
Local $iRegion = 3
_ArrayAdd($aDBKeyValue, 'country_code|||')
Local $iCountry_code = 4
_ArrayAdd($aDBKeyValue, 'rev||Rev |"')
Local $iRev = 5
_ArrayAdd($aDBKeyValue, 'proto|||')
Local $iProto = 6
_ArrayAdd($aDBKeyValue, 'video_format|||')
Local $iVideo_format = 7
_ArrayAdd($aDBKeyValue, 'file_type|||')
Local $iFile_type = 8
_ArrayAdd($aDBKeyValue, 'size||size="|"')
Local $iSize = 9
_ArrayAdd($aDBKeyValue, 'crc||crc="|"')
Local $iCrc = 10
_ArrayAdd($aDBKeyValue, 'md5||md5="|"')
Local $iMd5 = 11
_ArrayAdd($aDBKeyValue, 'sha1||sha1="|"')
Local $iSha1 = 12
_ArrayAdd($aDBKeyValue, 'disk|||')
Local $iDisk = 13
_ArrayAdd($aDBKeyValue, 'cloneof||cloneof="|"')
Local $iCloneof = 14
_ArrayAdd($aDBKeyValue, 'description||<description>|</description>')
Local $iDescription = 15
_ArrayAdd($aDBKeyValue, 'release_name||<release name="|"')
Local $iRelease_name = 16
_ArrayAdd($aDBKeyValue, 'rom_name||<rom name="|"')
Local $iRom_name = 17
_ArrayAdd($aDBKeyValue, 'status||status="|"')
Local $iStatus = 18
_ArrayAdd($aDBKeyValue, 'notes|||')
Local $iNotes = 19
; end of game data
Local $iDBGameDataEnd = 19
; ---- header - key/value
Local $iDBHeaderDataStart = 20
_ArrayAdd($aDBKeyValue, 'header_name||<name>|</name>')
Local $iHeader_name = 20
_ArrayAdd($aDBKeyValue, 'header_description||<description>|</description>')
Local $iHeader_description = 21
_ArrayAdd($aDBKeyValue, 'header_clrmamepro||<clrmamepro header="|"/>')
Local $iHeader_clrmamepro = 22
_ArrayAdd($aDBKeyValue, 'header_romcenter_plugin||<romcenter plugin="|"/>')
Local $iHeader_romcenter_plugin = 23
_ArrayAdd($aDBKeyValue, 'header_version||<version>|</version>')
Local $iHeader_version = 24
_ArrayAdd($aDBKeyValue, 'header_date||<date>|</date>')
Local $iHeader_date = 25
_ArrayAdd($aDBKeyValue, 'header_author||<author>|</author>')
Local $iHeader_author = 26
_ArrayAdd($aDBKeyValue, 'header_url||<url>|</url>')
Local $iHeader_url = 27
; end of header data
Local $iDBHeaderDataEnd = 27
;_ArrayDisplay($aDBKeyValue, "Results from the query")

Start()
Func Start()
	$hDB = StartDB($sDBFile, $aDBKeyValue)
	ConsoleLog($aDBKeyValue)

	; capture files
	Local $aRomFiles = ArrayOfFilesFromPath($sDatFolder)

	; loop over files
	For $sFile In $aRomFiles
		ConsoleLog('new file')
		Local $isHeaderDataLoaded = False
		;Local $isGameDataLoaded = False
		Local $aRomName[0]
		ConsoleLog($aRomName)

		; capture game data
		Local $aRows = ArrayOfFileContents($sFile)
		For $sRow In $aRows

			;ConsoleLog('==================================')
			;ConsoleLog('new row')
			;ConsoleLog($sRow)

			Select
				Case Not $isHeaderDataLoaded And StringInStr($sRow, '<?xml version')
					; do nothing
				Case Not $isHeaderDataLoaded And StringInStr($sRow, '<!DOCTYPE')
					; do nothing
				Case Not $isHeaderDataLoaded And StringInStr($sRow, '<datafile>')
					; do nothing
				Case Not $isHeaderDataLoaded And StringInStr($sRow, '<header>')
					; do nothing
				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_name][$iDbDelLeft])
					$aDBKeyValue[$iHeader_name][$iDbValue] = StringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_name][$iDbDelLeft], $aDBKeyValue[$iHeader_name][$iDbDelRight])

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_description][$iDbDelLeft])
					$aDBKeyValue[$iHeader_description][$iDbValue] = StringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_description][$iDbDelLeft], $aDBKeyValue[$iHeader_description][$iDbDelRight])

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_clrmamepro][$iDbDelLeft])
					$aDBKeyValue[$iHeader_clrmamepro][$iDbValue] = StringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_clrmamepro][$iDbDelLeft], $aDBKeyValue[$iHeader_clrmamepro][$iDbDelRight])

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_romcenter_plugin][$iDbDelLeft])
					$aDBKeyValue[$iHeader_romcenter_plugin][$iDbValue] = StringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_romcenter_plugin][$iDbDelLeft], $aDBKeyValue[$iHeader_romcenter_plugin][$iDbDelRight])

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_version][$iDbDelLeft])
					$aDBKeyValue[$iHeader_version][$iDbValue] = StringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_version][$iDbDelLeft], $aDBKeyValue[$iHeader_version][$iDbDelRight])

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_date][$iDbDelLeft])
					$aDBKeyValue[$iHeader_date][$iDbValue] = StringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_date][$iDbDelLeft], $aDBKeyValue[$iHeader_date][$iDbDelRight])

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_author][$iDbDelLeft])
					$aDBKeyValue[$iHeader_author][$iDbValue] = StringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_author][$iDbDelLeft], $aDBKeyValue[$iHeader_author][$iDbDelRight])

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_url][$iDbDelLeft])
					$aDBKeyValue[$iHeader_url][$iDbValue] = StringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_url][$iDbDelLeft], $aDBKeyValue[$iHeader_url][$iDbDelRight])

				Case Not $isHeaderDataLoaded And StringInStr($sRow, '</header>')
					$isHeaderDataLoaded = True

				Case StringInStr($sRow, $aDBKeyValue[$iGame_name][$iDbDelLeft])
					ConsoleLog('===========================================')
					$aDBKeyValue[$iGame_name][$iDbValue] = FixFormatting(RestoreGameTitle(StringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iGame_name][$iDbDelLeft], $aDBKeyValue[$iGame_name][$iDbDelRight])))
					$date = ''
					$publisher = ''
					$country_code = ''
					$aDBKeyValue[$iRev][$iDbValue] = GetRevNumber(StringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iRev][$iDbDelLeft], $aDBKeyValue[$iRev][$iDbDelRight]))
					$proto = ''
					$video_format = ''
					$aDBKeyValue[$iCloneof][$iDbValue] = StringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iCloneof][$iDbDelLeft], $aDBKeyValue[$iCloneof][$iDbDelRight])
					;Local $aDelRight = StringSplit($sRow, '<game name="', $STR_ENTIRESPLIT + $STR_NOCOUNT)

				Case StringInStr($sRow, $aDBKeyValue[$iDescription][$iDbDelLeft])
					$aDBKeyValue[$iDescription][$iDbValue] = StringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iDescription][$iDbDelLeft], $aDBKeyValue[$iDescription][$iDbDelRight])

				Case StringInStr($sRow, $aDBKeyValue[$iRelease_name][$iDbDelLeft])
					$aDBKeyValue[$iRelease_name][$iDbValue] = StringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iRelease_name][$iDbDelLeft], $aDBKeyValue[$iRelease_name][$iDbDelRight])
					$aDBKeyValue[$iRegion][$iDbValue] = StringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iRegion][$iDbDelLeft], $aDBKeyValue[$iRegion][$iDbDelRight])

				Case StringInStr($sRow, '<rom name=')
					; rom name, file type, size, crc, md5, sha1, status
					Local $rom_name = StringBetweenTwoDelimiters($sRow, '<rom name="', '"')
					Local $disk = AppendToNonEmpty(StringBetweenTwoDelimiters($sRow, '1of', ')'), '1 of ')
					Local $file_type = StringRight($rom_name, 3)
					Local $size = StringBetweenTwoDelimiters($sRow, 'size="', '"')
					Local $crc = StringBetweenTwoDelimiters($sRow, 'crc="', '"')
					Local $md5 = StringBetweenTwoDelimiters($sRow, 'md5="', '"')
					Local $sha1 = StringBetweenTwoDelimiters($sRow, 'sha1="', '"')
					Local $status = StringBetweenTwoDelimiters($sRow, 'status="', '"')
					_ArrayAdd($aRomName, $rom_name & '_' & $disk & '_' & $file_type & '_' & $size & '_' & $crc & '_' & $md5 & '_' & $sha1 & '_' & $status, $ARRAYFILL_FORCE_SINGLEITEM)

				Case StringInStr($sRow, '</game>')
					For $sRom In $aRomName
						Local $aValue = StringSplit($sRom, '_', $STR_NOCOUNT)

						$aDBKeyValue[$iRom_name][$iDbValue]  = $aValue[0]
						$aDBKeyValue[$iDisk][$iDbValue] 	 = $aValue[1]
						$aDBKeyValue[$iFile_type][$iDbValue] = $aValue[2]
						$aDBKeyValue[$iSize][$iDbValue] 	 = $aValue[3]
						$aDBKeyValue[$iCrc][$iDbValue] 		 = $aValue[4]
						$aDBKeyValue[$iMd5][$iDbValue] 		 = $aValue[5]
						$aDBKeyValue[$iSha1][$iDbValue] 	 = $aValue[6]
						$aDBKeyValue[$iStatus][$iDbValue]    = $aValue[7]
						InsertToDB($hDB, $aDBKeyValue)
					Next

					; reset rom_name array
					Local $aRomName[0]

					; reset values for next game title
					For $iIndex = $iDBGameDataStart To $iDBGameDataEnd
						$aDBKeyValue[$iIndex][$iDbValue] = ""
					Next

				Case StringInStr($sRow, '</datafile>')
					;End of File

				Case Else
					ConsoleLog('missing data')
					$notes = 'nothing found'

			EndSelect
		Next
	Next

	;_ArrayDisplay($aDBKeyValue, "Results from the query")

	StopDB($hDB, true, true)
EndFunc

; *************************************************
;
; *************************************************
Func AppendToNonEmpty($string, $sAppend)
	If $string == 0 Or $string == '' Then
		Return ''
	Else
		Return $sAppend & $string
	EndIf
EndFunc

; *************************************************
; Detect rows that have been skipped
; *************************************************
Func CheckSkippedRow($sRow, $isSomethingDedected)
	If Not $isSomethingDedected Then
		Select
			Case StringInStr($sRow, '<?xml version=')
			Case StringInStr($sRow, '<!DOCTYPE')
			Case StringInStr($sRow, '<datafile>')
			Case StringInStr($sRow, '<header>')
			Case StringInStr($sRow, '<name>')
			Case StringInStr($sRow, '<description>')
			Case StringInStr($sRow, '<clrmamepro')
			Case StringInStr($sRow, '<romcenter')
			Case StringInStr($sRow, '<version>')
			Case StringInStr($sRow, '<date>')
			Case StringInStr($sRow, '<author>')
			Case StringInStr($sRow, '<url>')
			Case StringInStr($sRow, '</header>')
			Case StringInStr($sRow, '</game>')
			Case StringInStr($sRow, '</datafile>')
				; Ignore rows containing the above identifiers
			Case Else
				ConsoleLog('WARN - nothing found for row: >' & $sRow & '<')
		EndSelect
	EndIf
EndFunc

; *************************************************
;
; *************************************************
Func StringBetweenTwoDelimiters($string, $sDelLeft, $sDelRight)
	If $sDelLeft <> "" AND $sDelRight <> "" Then
		Local $aDelLeft = StringSplit($string, $sDelLeft, $STR_ENTIRESPLIT + $STR_NOCOUNT)

		If UBound($aDelLeft) > 1 Then
			Local $aDelRight = StringSplit($aDelLeft[1], $sDelRight, $STR_ENTIRESPLIT + $STR_NOCOUNT)
			Return $aDelRight[0]
		EndIf
	EndIf

	; return empty string when nothing found
	Return ''
EndFunc

; *************************************************
; Stop DB
; *************************************************
Func InsertToDB($hDB, $aDBKeyValue)

	Local $sNewTableValues = ''
	For $iIndex = 0 To UBound($aDBKeyValue, $UBOUND_ROWS) - 1
		$sNewTableValues = $sNewTableValues & $aDBKeyValue[$iIndex][1] & '","'
	Next

	$sNewTableValues = StringTrimRight($sNewTableValues, 3)
	;ConsoleLog($sNewTableValues)
	;date","publisher","region","country_code","rev","proto","video_format","file_type","size","crc","md5","sha1","cloneof","description","release_name","rom_name","status","notes","header_name","header_description","header_clrmamepro","header_romcenter_plugin","header_version","header_date","header_author","header_url

	;_SQLite_Exec($hDatabase, 'INSERT INTO Roms VALUES ("' & $game_name & '","' & $date & '","' & _
	;_SQLite_Exec($hDB, 'INSERT INTO Roms VALUES (' & $game_name & '","' & ');')

	_SQLite_Exec($hDB, 'INSERT INTO Roms VALUES ("' & $sNewTableValues & '");')
EndFunc

; *************************************************
; Start DB
; *************************************************
Func StartDB($hDB, $aDBKeyValue)
	; Load the SQLite DLL
	_SQLite_Startup()
	ErrorCheck(@error, -1, 'Unable to start SQLite, Please verify your DLL.')

	; Create the database file and get the handle for the database
	$hDB = _SQLite_Open(@ScriptDir & '\SQLiteTestDatabase.db')
	ErrorCheck(@error, 1, 'Error Calling SQLite API "sqlite3_open_v2"')
	ErrorCheck(@error, 2, 'Error while converting filename to UTF-8')
	ErrorCheck(@error, 3, '_SQLite_Startup() not yet called')

	; create database table
	Local $sNewTableValues = ''
	For $iIndex = 0 To UBound($aDBKeyValue, $UBOUND_ROWS) - 1
		$sNewTableValues = $sNewTableValues & $aDBKeyValue[$iIndex][0] & ','
	Next

	_SQLite_Exec($hDB, 'CREATE TABLE Roms (' & StringTrimRight($sNewTableValues, 1) & ');')
	;_SQLite_Exec($hDB, 'CREATE TABLE Roms (game_name, date, publisher, region, country_code, rev, proto, video_format, file_type, size, crc, md5, sha1, cloneof, description, release_name, rom_name, status, notes, header_name, header_description, header_clrmamepro, header_romcenter_plugin, header_version, header_date, header_author, header_url);')
	ErrorCheck(@error, 1, 'Error calling SQLite API "sqlite3_exec"')
	ErrorCheck(@error, 2, 'Call prevented by SafeMode')
	ErrorCheck(@error, 3, 'Error Processing Callback from within _SQLite_GetTable2d()')
	ErrorCheck(@error, 4, 'Error while converting SQL statement to UTF-8')

	Return $hDB
EndFunc

; *************************************************
; Stop DB
; *************************************************
Func StopDB($hDatabase, $isDisplayed, $isTableDeleted)
	Local $aResult, $iRows, $iColumns ; $iRows and $iColuums are useless but they cannot be omitted from the function call so we declare them
	_SQLite_GetTable2d($hDatabase, 'SELECT * FROM Roms;', $aResult, $iRows, $iColumns) ; SELECT everything FROM "Roms" TABLE and get the $aResult
	If $isDisplayed Then _ArrayDisplay($aResult, "Results from the query")
	If $isTableDeleted Then _SQLite_Exec(-1, 'DROP TABLE Roms;')

	_SQLite_Close($hDatabase)
	_SQLite_Shutdown()
EndFunc

; *************************************************
;
; *************************************************
Func GetDate($string)
	Local $test = StringSplit(StringSplit($string, '(', $STR_ENTIRESPLIT + $STR_NOCOUNT)[1], ')', $STR_ENTIRESPLIT + $STR_NOCOUNT)[0]

	;If StringRegExp($test, '(19|20)\d\d|19xx|20xx') Then
		ConsoleLog('=================================')
		ConsoleLog($string)
		;Local $test = StringRegExp($string, '(19|20)\d\d|19xx|20xx', $STR_REGEXPARRAYGLOBALFULLMATCH )
		ConsoleLog($test)
		Return $test
	;EndIf
EndFunc

; *************************************************
; Capture Rev# from game title
; e.g.
; "Rev PRG0" from "Tao of 007 Rev PRG0, The (2002)(Quietust)[p]"
; "Rev B" 	 from "Richard Scarry's Busytown (1994-08-16)(Novotrade - Sega)(US)(proto)[Rev B]"
; *************************************************
Func GetRevNumber($string)
	Local $aList[5] = [", ", "(", "[", ")", "]"]
	For $sDelim In $aList
		If StringInStr($string, $sDelim) Then
			Local $aSplit = StringSplit($string, $sDelim, $STR_ENTIRESPLIT + $STR_NOCOUNT)
			If UBound($aSplit) > 0 Then
				$string = $aSplit[0]
			EndIf
		EndIf
	Next

	Return AppendToNonEmpty($string, 'Rev ')
EndFunc

; *************************************************
; Fix game title e.g. "Hunt for Red October, The" to "The Hunt for Red October"
; *************************************************
Func RestoreGameTitle($string)
	Local $aList[10] = ["The ", "A ", "Le ", "La ", "Les ", "L'", "Die ", "De ", "Der ", "El "]
	Local $stringNew = $string

	; loop over prefix list
	For $sPrefix In $aList
		; check for prefix in title
		If StringInStr($string, ', ' & $sPrefix) Then
			; Move prefix to begging of Title
			$stringNew = $sPrefix & StringReplace($string, ', ' & $sPrefix, ' ')
			ExitLoop
		EndIf
	Next

	; Remove "Rev #" from game title
	If StringInStr($stringNew, ' Rev ') Then
		Local $aSplit = StringSplit($stringNew, ' Rev ', $STR_ENTIRESPLIT + $STR_NOCOUNT)
		If UBound($aSplit) > 0 Then
			$stringNew = $aSplit[0]
		EndIf
	EndIf

	Return $stringNew
EndFunc

; *************************************************
; Fix white space and special char
; *************************************************
Func FixFormatting($string)
	If IsArray($string) Then
		Local $aNew[0]
		For $string In $string
			_ArrayAdd($aNew, Formatting($string))
		Next
		Return $aNew
	Else
		Return Formatting($string)
	EndIf
EndFunc

Func Formatting($string)
	; Remplace special characters
	If StringInStr($string, '&amp;') Then
		$string = StringReplace($string,'&amp;', '&')
	EndIf

	; remove "Enter" char 13 from string
	$string = StringStripCR($string)

	; remove white space
	$string = StringStripWS($string, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

	; return string
	Return $string
EndFunc

; *************************************************
; Return list of file Contents
; *************************************************
Func ArrayOfFileContents($file)
	Local $aArray = FileReadToArray($file)
	ErrorCheck(@error, 1, 'Error opening specified file.')
	ErrorCheck(@error, 2, 'Empty file.')

    ; Display the array in _ArrayDisplay.
    ;_ArrayDisplay($aArray)
	return $aArray
EndFunc

; *************************************************
; Return list of files from directory
; *************************************************
Func ArrayOfFilesFromPath($sPath)
	; Read files from directory
    Local $aFiles = _FileListToArray($sPath, '*.dat', $FLTA_FILES, True)
	ErrorCheck(@error, 1, 'Path was invalid.')
	ErrorCheck(@error, 2, 'Invalid $sFilter.')
	ErrorCheck(@error, 3, 'Invalid $iFlag.')
	ErrorCheck(@error, 4, 'No file(s) were found.')

	; Delete empty first index if found.
	Return ArrayDeleteFirstIndex($aFiles)
EndFunc

; *************************************************
; Error Checking
; *************************************************
Func ErrorCheck($iError, $iErrorNumber, $sErrorDescription)
	If $iError <> 0 Then
		If $iError = $iErrorNumber Then
			ConsoleWrite('Error ' & $iError & '  ' & $sErrorDescription & @CRLF)
			MsgBox($MB_SYSTEMMODAL, 'Error ' & $iError, $sErrorDescription)
			Exit
		Else
			;ConsoleWrite('Unknown Error ' & $iError & '  ' & $sErrorDescription & @CRLF)
			;MsgBox($MB_SYSTEMMODAL, 'Unknown Error ' & $iError, $sErrorDescription)
			;Exit
		EndIf
	EndIf
EndFunc

; *************************************************
; Remove first element index[0] when populated
; 	with count value or an empty string.
; *************************************************
Func ArrayDeleteFirstIndex($asArray)
	If (UBound($asArray) - 1) = $asArray[0] Or $asArray[0] = '' Then
		_ArrayDelete($asArray, 0)
	EndIf
	Return $asArray
EndFunc

; *************************************************
; Console logging
; *************************************************
Func ConsoleLog($asValue)
	If IsArray($asValue) Then
		For $string In $asValue
			ConsoleWrite($string & @CRLF)
		Next
	Else
		ConsoleWrite($asValue & @CRLF)
	EndIf
EndFunc
