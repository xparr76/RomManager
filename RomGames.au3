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
Local $debug 	     = False	; turn on debugging
Local $iDbKey 	     = 0
Local $iDbValue      = 1
Local $iDbDelLeft    = 2
Local $iDbDelRight   = 3
Local $iDbIndexLeft  = 4
Local $iDbIndexRight = 5
; initialize DB keys
Local $aDBKeyValue[0][6]
; column titles
;$aDBKeyValue[0][$iDbKey] 	   = 'key'
;$aDBKeyValue[0][$iDbValue]    = 'value'
;$aDBKeyValue[0][$iDbDelLeft]  = 'delimiter_left'
;$aDBKeyValue[0][$iDbDelRight] = 'delimiter_right'
; game data - key/value
Local $iDBGameDataStart = 0
Local $iDBGameDataEnd   = 18
_ArrayAdd($aDBKeyValue, 'game_name||<game name="|(|1|0')
_ArrayAdd($aDBKeyValue, 'date||||1|0')
_ArrayAdd($aDBKeyValue, 'publisher||||1|0')
_ArrayAdd($aDBKeyValue, 'region||||1|0')
_ArrayAdd($aDBKeyValue, 'country_code||||1|0')
_ArrayAdd($aDBKeyValue, 'rev||Rev |"|1|0')
_ArrayAdd($aDBKeyValue, 'proto||||1|0')
_ArrayAdd($aDBKeyValue, 'video_format||||1|0')
_ArrayAdd($aDBKeyValue, 'file_type||||1|0')
_ArrayAdd($aDBKeyValue, 'size||size="|"|1|0')
_ArrayAdd($aDBKeyValue, 'crc||crc="|"|1|0')
_ArrayAdd($aDBKeyValue, 'md5||md5="|"|1|0')
_ArrayAdd($aDBKeyValue, 'sha1||sha1="|"|1|0')
_ArrayAdd($aDBKeyValue, 'cloneof||cloneof="|"|1|0')
_ArrayAdd($aDBKeyValue, 'description||<description>|</description>|1|0')
_ArrayAdd($aDBKeyValue, 'release_name||<release name="|"|1|0')
_ArrayAdd($aDBKeyValue, 'rom_name||<rom name="|"|1|0')
_ArrayAdd($aDBKeyValue, 'status||status="|"|1|0')
_ArrayAdd($aDBKeyValue, 'notes||||1|0')
; header - key/value
Local $iDBHeaderDataStart = 19
Local $iDBHeaderDataEnd   = 27
_ArrayAdd($aDBKeyValue, 'header_name||<name>|</name>|1|0')
_ArrayAdd($aDBKeyValue, 'header_description||<description>|</description>|1|0')
_ArrayAdd($aDBKeyValue, 'header_clrmamepro||<clrmamepro header="|"/>|1|0')
_ArrayAdd($aDBKeyValue, 'header_romcenter_plugin||<romcenter plugin="|"/>|1|0')
_ArrayAdd($aDBKeyValue, 'header_version||<version>|</version>|1|0')
_ArrayAdd($aDBKeyValue, 'header_date||<date>|</date>|1|0')
_ArrayAdd($aDBKeyValue, 'header_author||<author>|</author>|1|0')
_ArrayAdd($aDBKeyValue, 'header_url||<url>|</url>|1|0')
;_ArrayDisplay($aDBKeyValue, "Results from the query")

Start()
Func Start()
	$hDB = StartDB($sDBFile, $aDBKeyValue)
	ConsoleLog($aDBKeyValue)

	; capture files
	Local $aRomFiles = ArrayOfFilesFromPath($sDatFolder)

	; loop over files
	For $sFile In $aRomFiles
		Local $isHeaderDataLoaded = false	; reset after each new file is loaded
		Local $isNewGameTitle = False

		; capture game data
		Local $aRow = ArrayOfFileContents($sFile)
		For $sRow In $aRow
			Local $isSomethingDedected = False

			; loop over array of game data points to capture
			For $iIndex = 0 To UBound($aDBKeyValue, $UBOUND_ROWS) - 1
				Local $key 		 = $aDBKeyValue[$iIndex][$iDbKey]
				Local $value 	 = $aDBKeyValue[$iIndex][$iDbValue]
				Local $sDelLeft  = $aDBKeyValue[$iIndex][$iDbDelLeft]
				Local $sDelRight = $aDBKeyValue[$iIndex][$iDbDelRight]
				Local $iLeft 	 = $aDBKeyValue[$iIndex][$iDbIndexLeft]
				Local $iRight 	 = $aDBKeyValue[$iIndex][$iDbIndexRight]

				; only check header data once from array keys "$aDBKeyValue"
				If $isHeaderDataLoaded AND $iIndex >= $iDBHeaderDataStart Then
					ContinueLoop
				EndIf

				; check each line for left delimiter designated in $aDBKeyValue array
				If StringRegExp($sRow, $sDelLeft) AND $sDelLeft <> "" Then
					;ConsoleLog('=================================')
					;ConsoleLog($key)

					; string split the target value
					Local $sValue = StringBetweenTwoDelimiters($sRow, $sDelLeft, $sDelRight, $iLeft, $iRight)

                    If $key = 'game_name' Then
                        $sValue = RestoreGameTitle($sValue)
                    EndIf

                    If $key = 'rev' Then
                        $sValue = GetRevNumber($sValue)
                    EndIf

					; remove extra characters
					$sValue = FixFormatting($sValue)

					; save new value to array
					$aDBKeyValue[$iIndex][$iDbValue] = $sValue

					; mark found something in row
					$isSomethingDedected = True
				EndIf

				;Select
                ;    ; clean up game title
                ;    Case $key = 'game_name'
                ;        $sValue = RestoreGameTitle($sValue)
;
                ;    ; get Date value from game title
                ;    Case $key = 'date'
                ;        ;$sValue = GetDate($sValue)
                ;        $sValue = 'date'
                ;        ;ConsoleLog($sValue)
;
                ;    ;
                ;    Case $key = 'rom_name'
                ;        $sValue = 'rom_name'
;
                ;    ;
                ;    Case $key = 'publisher'
                ;        $sValue = 'publisher'
;
                ;    ;
                ;    Case $key = 'region'
                ;        $sValue = 'region'
;
                ;    ;
                ;    Case $key = 'country_code'
                ;        $sValue = 'country_code'
;
                ;    ; get Rev #
                ;    Case $key = 'rev'
                ;        $sValue = GetRevNumber($sValue)
;
                ;    ;
                ;    Case $key = 'proto'
                ;        $sValue = 'proto'
;
                ;    ;
                ;    Case $key = 'video_format'
                ;        $sValue = 'video_format'
;
                ;    ;
                ;    Case $key = 'file_type'
                ;        $sValue = 'file_type'
;
                ;EndSelect

				; check if header data has loaded
				If $isHeaderDataLoaded = False AND StringRegExp($sRow, '</header>') Then $isHeaderDataLoaded = True

				; check for the start of next game title
				If $isNewGameTitle = False AND StringRegExp($sRow, '<game name="') Then $isNewGameTitle = True
			Next

			; insert data into DB after All info for EACH game title is found
			If $isHeaderDataLoaded AND $isNewGameTitle AND StringRegExp($sRow, '</game>') Then
				InsertToDB($hDB, $aDBKeyValue)
				$isNewGameTitle = False

				; clear captured Values only, leave header Values
				For $iIndex = $iDBGameDataStart To $iDBGameDataEnd
					$aDBKeyValue[$iIndex][$iDbValue] = ""
				Next
			EndIf

			CheckSkippedRow($sRow, $isSomethingDedected)
		Next

		; clear all Values from array for next file
		For $iIndex = 0 To UBound($aDBKeyValue, $UBOUND_ROWS) - 1
			$aDBKeyValue[$iIndex][$iDbValue] = ""
		Next
	Next

	;_ArrayDisplay($aDBKeyValue, "Results from the query")

	StopDB($hDB, true, true)
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
Func StringBetweenTwoDelimiters($string, $sDelLeft, $sDelRight, $iLeft, $iRight)
	If $sDelLeft <> "" AND $sDelRight <> "" Then
		Local $aDelLeft = StringSplit($string, $sDelLeft, $STR_ENTIRESPLIT + $STR_NOCOUNT)
		;ConsoleLog('UBound($aDelLeft): ' & UBound($aDelLeft) & '  $iLeft: ' & $iLeft & '  $sDelLeft: ' & $sDelLeft)
		;ConsoleLog($aDelLeft)

		If UBound($aDelLeft) > 1 Then

			;If UBound($sDelRight) >= $iRight Then
				Local $aDelRight = StringSplit($aDelLeft[1], $sDelRight, $STR_ENTIRESPLIT + $STR_NOCOUNT)
				;ConsoleLog('UBound($aDelRight): ' & UBound($aDelRight) & '  $iRight: ' & $iRight & '  $sDelRight: ' & $sDelRight)
				;ConsoleLog($aDelRight)

				Return $aDelRight[0]
			;EndIf
		EndIf
	EndIf
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

	Return 'Rev ' & $string
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
Func FixFormatting($old)
	If IsArray($old) Then
		Local $aNew[0]
		For $string In $old
			_ArrayAdd($aNew, Formatting($string))
		Next
		Return $aNew
	Else
		Return Formatting($old)
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
