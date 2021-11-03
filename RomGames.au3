#AutoIt3Wrapper_UseX64=Y ;(Y/N) Use AutoIt3_x64 or Aut2Exe_x64. Default=N
#include <Array.au3>
#include <SQLite.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>


; Title version (demo) (date)(publisher)(system)(video)(country)(language)(copyright)(devstatus)(media type)(media label)[cr][f][h][m][p][t][tr][o][u][v][b][a][!][more info]
; ---------------------------
; ---------- Start ----------
; ---------------------------
; capture game data

Local $afCodeDemo    = ArrayOfFileContents(@ScriptDir & '\Resources\code_demo.csv')
Local $afPublisher   = ArrayOfFileContents(@ScriptDir & '\Resources\code_publisher.csv')
Local $afSystem   	 = ArrayOfFileContents(@ScriptDir & '\Resources\code_system.csv')
Local $afCodeVideo   = ArrayOfFileContents(@ScriptDir & '\Resources\code_video.csv')
Local $afCodeCountry = ArrayOfFileContents(@ScriptDir & '\Resources\code_country.csv')
Local $afLanguage 	 = ArrayOfFileContents(@ScriptDir & '\Resources\code_language.csv')
Local $afCopyright 	 = ArrayOfFileContents(@ScriptDir & '\Resources\code_copyright.csv')
Local $afDevStatus   = ArrayOfFileContents(@ScriptDir & '\Resources\code_devstatus.csv')
Local $afMediaType   = ArrayOfFileContents(@ScriptDir & '\Resources\code_media_type.csv')
Local $afMediaLabel  = ArrayOfFileContents(@ScriptDir & '\Resources\code_media_label.csv')
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
_ArrayAdd($aDBKeyValue, 'title||<game name="|(')
Local $iTitle = 0
_ArrayAdd($aDBKeyValue, 'rev||Rev |"')
Local $iRev = 1
_ArrayAdd($aDBKeyValue, 'demo|||')
Local $iDemo = 2
_ArrayAdd($aDBKeyValue, 'date|||')
Local $iDate = 3
_ArrayAdd($aDBKeyValue, 'publisher|||')
Local $iPublisher = 4
_ArrayAdd($aDBKeyValue, 'system|||')
Local $iSystem = 5
_ArrayAdd($aDBKeyValue, 'video|||')
Local $iVideo = 6
_ArrayAdd($aDBKeyValue, 'country|||')
Local $iCountry = 7
_ArrayAdd($aDBKeyValue, 'language|||')
Local $iLanguage = 8
_ArrayAdd($aDBKeyValue, 'copyright|||')
Local $iCopyright = 9
_ArrayAdd($aDBKeyValue, 'devstatus|||')
Local $iDevStatus = 10
_ArrayAdd($aDBKeyValue, 'media_type|||')
Local $iMedia_Type = 11
_ArrayAdd($aDBKeyValue, 'media_label|||')
Local $iMedia_Label = 12
_ArrayAdd($aDBKeyValue, 'cr|||')
Local $iCracked = 13
_ArrayAdd($aDBKeyValue, 'f|||')
Local $iFixed = 14
_ArrayAdd($aDBKeyValue, 'h|||')
Local $iHack = 15
_ArrayAdd($aDBKeyValue, 'm|||')
Local $iModified = 16
_ArrayAdd($aDBKeyValue, 'p|||')
Local $iPirate = 17
_ArrayAdd($aDBKeyValue, 't|||')
Local $iTrained = 18
_ArrayAdd($aDBKeyValue, 'tr|||')
Local $iTranslated = 19
_ArrayAdd($aDBKeyValue, 'o|||')
Local $iOverDump = 20
_ArrayAdd($aDBKeyValue, 'u|||')
Local $iUnderDumped = 21
_ArrayAdd($aDBKeyValue, 'v|||')
Local $iVirus = 22
_ArrayAdd($aDBKeyValue, 'b|||')
Local $iBadDump = 23
_ArrayAdd($aDBKeyValue, 'a|||')
Local $iAlternate = 24
_ArrayAdd($aDBKeyValue, 'verified|||')
Local $iVerified = 25
_ArrayAdd($aDBKeyValue, 'more_info|||')
Local $iMoreInfo = 26
_ArrayAdd($aDBKeyValue, 'region||region="|"')
Local $iRegion = 27
_ArrayAdd($aDBKeyValue, 'file_type|||')
Local $iFile_type = 28
_ArrayAdd($aDBKeyValue, 'size||size="|"')
Local $iSize = 29
_ArrayAdd($aDBKeyValue, 'crc||crc="|"')
Local $iCrc = 30
_ArrayAdd($aDBKeyValue, 'md5||md5="|"')
Local $iMd5 = 31
_ArrayAdd($aDBKeyValue, 'sha1||sha1="|"')
Local $iSha1 = 32
_ArrayAdd($aDBKeyValue, 'disk|||')
Local $iDisk = 33
_ArrayAdd($aDBKeyValue, 'cloneof||cloneof="|"')
Local $iCloneof = 34
_ArrayAdd($aDBKeyValue, 'game_name||<game name="|"')
Local $iGame_Name = 35
_ArrayAdd($aDBKeyValue, 'description||<description>|</description>')
Local $iDescription = 36
_ArrayAdd($aDBKeyValue, 'release_name||<release name="|"')
Local $iRelease_Name = 37
_ArrayAdd($aDBKeyValue, 'rom_name||<rom name="|"')
Local $iRom_Name = 38
_ArrayAdd($aDBKeyValue, 'status||status="|"')
Local $iStatus = 39
; end of game data
Local $iDBGameDataEnd = 39
; ---- header - key/value
Local $iDBHeaderDataStart = 40
_ArrayAdd($aDBKeyValue, 'header_name||<name>|</name>')
Local $iHeader_name = 40
_ArrayAdd($aDBKeyValue, 'header_description||<description>|</description>')
Local $iHeader_description = 41
_ArrayAdd($aDBKeyValue, 'header_category||<category>|</category>')
Local $iHeader_category = 42
_ArrayAdd($aDBKeyValue, 'header_clrmamepro||<clrmamepro header="|"/>')
Local $iHeader_clrmamepro = 43
_ArrayAdd($aDBKeyValue, 'header_romcenter_plugin||<romcenter plugin="|"/>')
Local $iHeader_romcenter_plugin = 44
_ArrayAdd($aDBKeyValue, 'header_version||<version>|</version>')
Local $iHeader_version = 45
_ArrayAdd($aDBKeyValue, 'header_date||<date>|</date>')
Local $iHeader_date = 46
_ArrayAdd($aDBKeyValue, 'header_author||<author>|</author>')
Local $iHeader_author = 47
_ArrayAdd($aDBKeyValue, 'header_email||<email>|</email>')
Local $iHeader_email = 48
_ArrayAdd($aDBKeyValue, 'header_homepage||<homepage>|</homepage>')
Local $iHeader_homepage = 49
_ArrayAdd($aDBKeyValue, 'header_url||<url>|</url>')
Local $iHeader_url = 50
; end of header data
Local $iDBHeaderDataEnd = 50
;_ArrayDisplay($aDBKeyValue, "Results from the query")

Start()
Func Start()
	$hDB = StartDB($sDBFile, $aDBKeyValue)

	; capture files
	Local $aRomFiles = ArrayOfFilesFromPath($sDatFolder)

	; loop over files
	For $sFile In $aRomFiles
		ConsoleLog('new file')
		Local $isHeaderDataLoaded = False
		Local $aRomName[0]
		ConsoleLog($aRomName)

		; capture game data
		Local $aRows = ArrayOfFileContents($sFile)
		For $sRow In $aRows
			Local $isEndOfGameTitle = False

			Select
				Case $sRow = ''
					; do nothing
				Case Not $isHeaderDataLoaded And StringInStr($sRow, '<?xml version')
					; do nothing
				Case Not $isHeaderDataLoaded And StringInStr($sRow, '<!DOCTYPE')
					; do nothing
				Case Not $isHeaderDataLoaded And StringInStr($sRow, '<datafile>')
					; do nothing
				Case Not $isHeaderDataLoaded And StringInStr($sRow, '<header>')
					; do nothing
				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_name][$iDbDelLeft])
					$aDBKeyValue[$iHeader_name][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_name][$iDbDelLeft], $aDBKeyValue[$iHeader_name][$iDbDelRight]))

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_description][$iDbDelLeft])
					$aDBKeyValue[$iHeader_description][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_description][$iDbDelLeft], $aDBKeyValue[$iHeader_description][$iDbDelRight]))

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_category][$iDbDelLeft])
					$aDBKeyValue[$iHeader_category][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_category][$iDbDelLeft], $aDBKeyValue[$iHeader_category][$iDbDelRight]))

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_clrmamepro][$iDbDelLeft])
					$aDBKeyValue[$iHeader_clrmamepro][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_clrmamepro][$iDbDelLeft], $aDBKeyValue[$iHeader_clrmamepro][$iDbDelRight]))

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_romcenter_plugin][$iDbDelLeft])
					$aDBKeyValue[$iHeader_romcenter_plugin][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_romcenter_plugin][$iDbDelLeft], $aDBKeyValue[$iHeader_romcenter_plugin][$iDbDelRight]))

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_version][$iDbDelLeft])
					$aDBKeyValue[$iHeader_version][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_version][$iDbDelLeft], $aDBKeyValue[$iHeader_version][$iDbDelRight]))

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_date][$iDbDelLeft])
					$aDBKeyValue[$iHeader_date][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_date][$iDbDelLeft], $aDBKeyValue[$iHeader_date][$iDbDelRight]))

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_author][$iDbDelLeft])
					$aDBKeyValue[$iHeader_author][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_author][$iDbDelLeft], $aDBKeyValue[$iHeader_author][$iDbDelRight]))

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_email][$iDbDelLeft])
					$aDBKeyValue[$iHeader_email][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_email][$iDbDelLeft], $aDBKeyValue[$iHeader_email][$iDbDelRight]))

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_homepage][$iDbDelLeft])
					$aDBKeyValue[$iHeader_homepage][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_homepage][$iDbDelLeft], $aDBKeyValue[$iHeader_homepage][$iDbDelRight]))

				Case Not $isHeaderDataLoaded And StringInStr($sRow, $aDBKeyValue[$iHeader_url][$iDbDelLeft])
					$aDBKeyValue[$iHeader_url][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iHeader_url][$iDbDelLeft], $aDBKeyValue[$iHeader_url][$iDbDelRight]))

				Case Not $isHeaderDataLoaded And StringInStr($sRow, '</header>')
					$isHeaderDataLoaded = True

				; parse "game name" row
				Case StringInStr($sRow, $aDBKeyValue[$iTitle][$iDbDelLeft])
					$aDBKeyValue[$iTitle][$iDbValue] = Formatting(RestoreGameTitle(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iTitle][$iDbDelLeft], $aDBKeyValue[$iTitle][$iDbDelRight])))
					$aDBKeyValue[$iGame_Name][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iGame_Name][$iDbDelLeft], $aDBKeyValue[$iGame_Name][$iDbDelRight]))
					Local $isRevFound = False
					Local $isDemoFound = False
					Local $isDateFound = False
					Local $isPublisherFound = False
					Local $isSystemFound = False
					Local $isVideoFound = False
					Local $isCountryFound = False
					Local $isLanguageFound = False
					Local $isCopyrightFound = False
					Local $isDevStatusFound = False
					Local $isMediaTypeFound = False
					Local $isMediaLabelFound = False
					Local $isMoreInfo = False

					; Title version (demo) (date)(publisher)(system)(video)(country)(language)(copyright)(devstatus)(media type)(media label)
					Local $gameName = GetStringBetweenTwoDelimiters($sRow, '<game name="', '"')
					Local $aSplit = StringSplit($gameName, '(', $STR_ENTIRESPLIT + $STR_NOCOUNT)
					For $i = 1 to UBound($aSplit) - 1
						Local $sValue = Formatting(StringSplit($aSplit[$i], ')', $STR_ENTIRESPLIT + $STR_NOCOUNT)[0])

						Select
							Case $sValue == '-' Or $sValue == 'Unknown'
								; do nothing

							Case Not $isRevFound And StringRegExp($sValue, '^(Rev|Rev\s.*?)$')
								; do nothing

							Case Not $isDemoFound And CheckResourceFile($sValue, $afCodeDemo)
								$isDemoFound = True
								$aDBKeyValue[$iDemo][$iDbValue] = $sValue

							Case Not $isDateFound And StringRegExp($sValue, '^((\d+(\/|-|,|.)\d+)|(\d+(\/|-|,|.)\d+(\/|-|,|.)\d+)|((January|February|March|April|May|June|July|August|September|October|November|December)(\/|-|,|.)?(\s+)?(\d+)?)|((Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)(\/|-|,|.)?(\s+)?(\d+)?)|19xx|198x|199x|20xx|200x)$')
								$isDateFound = True
								$aDBKeyValue[$iDate][$iDbValue] = $sValue

							;Case Not $isPublisherFound And CheckResourceFile($sValue, $afPublisher)
							Case Not $isPublisherFound And RegexOnResourceFile($sValue, '^(?-i)(?!PAL)(?i)', $afPublisher, '$')
								$isPublisherFound = True
								$aDBKeyValue[$iPublisher][$iDbValue] = $sValue

							;Case Not $isSystemFound And CheckResourceFile($sValue, $afSystem)
							Case Not $isSystemFound And RegexOnResourceFile($sValue, '^(?i)', $afSystem, '$')
								$isSystemFound = True
								$aDBKeyValue[$iSystem][$iDbValue] = $sValue

							;Case Not $isVideoFound And CheckResourceFile($sValue, $afCodeVideo)
							Case Not $isVideoFound And StringRegExp($sValue, '^(?i)((CGA|EGA|HGC|MCGA|MDA|NTSC|PAL|SECAM|SVGA|VGA|XGA)(_|-|\.|\s+)?(J|M|U|PAL|B|D|I|N|NC|60|NTSC)?)$')
								$isVideoFound = True
								$aDBKeyValue[$iVideo][$iDbValue] = $sValue

							Case Not $isCountryFound And RegexOnResourceFile($sValue, '^(?i)', $afCodeCountry, '(\+.*?|-.*?|,\s.*?)?$')
								$isCountryFound = True
								$aDBKeyValue[$iCountry][$iDbValue] = $sValue

							Case Not $isLanguageFound And RegexOnResourceFile($sValue, '^(?i)', $afLanguage, '(\+.*?|\-.*?|\,.*?)?$') Or StringRegExp($sValue, '(?i)M\d+')
								$isLanguageFound = True
								$aDBKeyValue[$iLanguage][$iDbValue] = $sValue

							Case Not $isCopyrightFound And CheckResourceFile($sValue, $afCopyright)
								$isCopyrightFound = True
								$aDBKeyValue[$iCopyright][$iDbValue] = $sValue

							;Case Not $isDevStatusFound And CheckResourceFile($sValue, $afDevStatus) Or StringRegExp($sValue, '(?i)(Proto\s\d|Beta\s\d)')
							Case Not $isDevStatusFound And StringRegExp($sValue, '^(?i)(alpha|beta|preview|pre(_|-|\.|\s+)release|proto)(\s\d+)?$')
								$isDevStatusFound = True
								$aDBKeyValue[$iDevStatus][$iDbValue] = $sValue

							Case Not $isMediaTypeFound And CheckResourceFile($sValue, $afMediaType) Or StringRegExp($sValue, '(?i)Disk\s\d+') Or StringRegExp($sValue, '(?i)Competition\sCart|NES\sTest)')
								$isMediaTypeFound = True
								$aDBKeyValue[$iMedia_Type][$iDbValue] = $sValue

							Case Not $isMediaLabelFound And CheckResourceFile($sValue, $afMediaLabel)
								$isMediaLabelFound = True
								$aDBKeyValue[$iMedia_Label][$iDbValue] = $sValue

							Case Else
								consoleLog('WARN  no match found: >' & $sValue & '< ' & '  ' & $sRow)
								;MsgBox($MB_SYSTEMMODAL, 'Nothing Matched: ', '>' & $_sOtherValue & '<')
								If $isMoreInfo Then
									$aDBKeyValue[$iMoreInfo][$iDbValue] = $aDBKeyValue[$iMoreInfo][$iDbValue] & '::' & $sValue
								Else
									$aDBKeyValue[$iMoreInfo][$iDbValue] = $aDBKeyValue[$iMoreInfo][$iDbValue] & $sValue
								EndIf
								; flip bool after first find
								$isMoreInfo = True

						EndSelect
					Next

					; [cr#] 												- [cr] Cracked
					; [cr Cracker] 											- [cr] Cracked - Cracked by Cracker (group or person)
					; [f#] 													- [f] Fixed - A fixed game has been altered in some way so that it will run better on a copier or emulator.
					; [f Fix] 												- [f] Fixed - Fix/amendment added
					; [f Fixer] 											- [f] Fixed - Fixed by Fixer (group or person)
					; [f Fix Fixer] 										- [f] Fixed - Fix added by Fixer (group or person)
					; [h#]													- [h] Hack - Something in this ROM is not quite as it should be. Often a hacked ROM simply has a changed header or has been enabled to run in different regions. Other times it could be a release group intro, or just some kind of cheating or funny hack.
					; [h Hack] 												– [h] Hack - Description of hack
					; [h Hacker] 											– [h] Hack - Hacked by (group or person)
					; [h Hack Hacker] 										– [h] Hack - Description of hack, followed by hacker (group or person)
					; [m#]													- [m] Modified
					; [m Modification]  									- [m] Modified - Modification added
					; [p#] 													- [p] Pirate
					; [p Pirate] 											- [p] Pirate - Pirate version by Pirate (group or person)
					; [t#] 													- [t] Trained - Special code which executes before the game is begun. It allows you to access cheats from a menu.
					; [t Trainer] 											- [t] Trained - Trained by trainer (group or person)
					; [t +x] 												- [t] Trained - x denotes number of trainers added
					; [t +x Trainer] 										- [t] Trained - Trained and x number of trainers added by trainer (group or person)
					; [tr#] 												- [tr] Translated
					; [tr language] 										- [tr] Translated - to Language
					; [tr language-partial] 								- [tr] Translated - to Language (partial translation)
					; [tr language Translator] 								- [tr] Translated - to Language by Translator (group or person)
					; [tr language1-language2] 								- [tr] Translated - to both Language1 and Language2.
					; [tr language1-partial-language2-partial Translator] 	- [tr] Translated - Partially translated to both Language1 and language2 by Translator (group or person).
					; [o#] 													- [o] Over Dump - ROM image has more data than is actually in the cart. The extra information means nothing and is removed from the true image.
					; [u#]													- [u] Under Dumped - (not enough data dumped)
					; [v]													- [v] Virus - (infected)
					; [v Virus] 											- [v] Virus - Infected with virus
					; [v Virus Version] 									- [v] Virus - Infected with virus of version
					; [b#] 													- [b] Bad Dump - often occurs with an older game or a faulty dumper (bad connection). Another common source of [b] ROMs is a corrupted upload to a release FTP.
					; [b Descriptor] 										- [b] Bad Dump - Bad dump (including reason)
					; [a#]													- [a] Alternate - This is simply an alternate version of a ROM. Many games have been re-released to fix bugs or even to eliminate Game Genie codes (Yes, Nintendo hates that device).
					; [a Descriptor]										- [a] Alternate - (including reason)
					; [!]													- [!] Verified Good Dump

					; Rom Flags [cr][f][h][m][p][t][tr][o][u][v][b][a][!][more info]
					;Local $isIgnoreFlags = False
					Local $isCracked = False
					Local $isFixed = False
					Local $isHack = False
					Local $isModified = False
					Local $isPirate = False
					Local $isTrained = False
					Local $isTranslated = False
					Local $isOverDump = False
					Local $isUnderDumped = False
					Local $isVirus = False
					Local $isBadDump = False
					Local $isAlternate = False
					Local $isVerified = False
					$isMoreInfo = False

					; split title on )
					Local $aRomFlagSplit = StringSplit($gameName, ')', $STR_ENTIRESPLIT + $STR_NOCOUNT)
					; grab data after last ) then split on [
					$aRomFlagSplit = StringSplit($aRomFlagSplit[UBound($aRomFlagSplit)-1], '[', $STR_ENTIRESPLIT + $STR_NOCOUNT)
					For $i = 1 to UBound($aRomFlagSplit) - 1
						; remove the trailing ]
						Local $sValue = Formatting(StringSplit($aRomFlagSplit[$i], ']', $STR_ENTIRESPLIT + $STR_NOCOUNT)[0])

						Select
							Case $sValue == ''
								; do nothing

							Case Not $isAlternate And StringRegExp($sValue, '^(Rev|Rev\s.*?)$')
								; do nothing

							Case Not $isCracked And StringRegExp($sValue, '^(cr|cr\d+|cr\s.*?|cr\d\s.*?)$')
								$isCracked = True
								$aDBKeyValue[$iCracked][$iDbValue] = $sValue

							Case Not $isFixed And StringRegExp($sValue, '^(f|f\d+|f\s.*?|f\d\s.*?)$')
								$isFixed = True
								$aDBKeyValue[$iFixed][$iDbValue] = $sValue

							Case Not $isHack And StringRegExp($sValue, '^(h|h\d+|h\s.*?|h\d\s.*?)$')
								$isHack = True
								$aDBKeyValue[$iHack][$iDbValue] = $sValue

							Case Not $isModified And StringRegExp($sValue, '^(m|m\d+|m\s.*?|m\d\s.*?)$')
								$isModified = True
								$aDBKeyValue[$iModified][$iDbValue] = $sValue

							Case Not $isPirate And StringRegExp($sValue, '^(p|p\d+|p\s.*?|p\d\s.*?)$')
								$isPirate = True
								$aDBKeyValue[$iPirate][$iDbValue] = $sValue

							Case Not $isTrained And StringRegExp($sValue, '^(t|t\d+|t\s.*?|t\d\s.*?)$')
								$isTrained = True
								$aDBKeyValue[$iTrained][$iDbValue] = $sValue

							Case Not $isTranslated And StringRegExp($sValue, '^(tr|tr\d+|tr\s.*?|tr\d\s.*?)$')
								$isTranslated = True
								$aDBKeyValue[$iTranslated][$iDbValue] = $sValue

							Case Not $isOverDump And StringRegExp($sValue, '^(o|o\d+)$')
								$isOverDump = True
								$aDBKeyValue[$iOverDump][$iDbValue] = $sValue

							Case Not $isUnderDumped And StringRegExp($sValue, '^(u|u\d+)$')
								$isUnderDumped = True
								$aDBKeyValue[$iUnderDumped][$iDbValue] = $sValue

							; don't think anyone uses this flag
							;Case Not $isVirus And StringRegExp($sValue, '^(v|v\d+|v\s.*?|v\d\s.*?)$')
								;$isVirus = True
								;$aDBKeyValue[$iVirus][$iDbValue] = $sValue

							Case Not $isBadDump And StringRegExp($sValue, '^(b|b\d+|b\s.*?|b\d\s.*?)$')
								$isBadDump = True
								$aDBKeyValue[$iBadDump][$iDbValue] = $sValue

							Case Not $isAlternate And StringRegExp($sValue, '^(a|a\d+|a\s.*?|a\d\s.*?)$')
								$isAlternate = True
								$aDBKeyValue[$iAlternate][$iDbValue] = $sValue

							Case Not $isVerified And StringRegExp($sValue, '^!$')
								$isVerified = True
								$aDBKeyValue[$iVerified][$iDbValue] = $sValue

							Case Else
								;consoleLog('WARN   ROM-FLAG not found: >' & $sValue & '< ' & '  ' & $sRow)
								;MsgBox($MB_SYSTEMMODAL, 'Nothing Matched: ', '>' & $_sOtherValue & '<')
								If $isMoreInfo Then
									$aDBKeyValue[$iMoreInfo][$iDbValue] = $aDBKeyValue[$iMoreInfo][$iDbValue] & ':' & $sValue
								Else
									$aDBKeyValue[$iMoreInfo][$iDbValue] = $aDBKeyValue[$iMoreInfo][$iDbValue] & $sValue
								EndIf
								; flip bool after first find
								$isMoreInfo = True

						EndSelect
					Next

					; get "Rev #"
					$aDBKeyValue[$iRev][$iDbValue] = Formatting(GetRevNumber(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iRev][$iDbDelLeft], $aDBKeyValue[$iRev][$iDbDelRight])))

					; get clone
					$aDBKeyValue[$iCloneof][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iCloneof][$iDbDelLeft], $aDBKeyValue[$iCloneof][$iDbDelRight]))

				; parse description row
				Case StringInStr($sRow, $aDBKeyValue[$iDescription][$iDbDelLeft])
					$aDBKeyValue[$iDescription][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iDescription][$iDbDelLeft], $aDBKeyValue[$iDescription][$iDbDelRight]))

				; parse "release name" row
				Case StringInStr($sRow, $aDBKeyValue[$iRelease_Name][$iDbDelLeft])
					$aDBKeyValue[$iRelease_Name][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iRelease_Name][$iDbDelLeft], $aDBKeyValue[$iRelease_Name][$iDbDelRight]))

					; TODO add multi regoin rows
					$aDBKeyValue[$iRegion][$iDbValue] = Formatting(GetStringBetweenTwoDelimiters($sRow, $aDBKeyValue[$iRegion][$iDbDelLeft], $aDBKeyValue[$iRegion][$iDbDelRight]))

				; parse "rom name" row
				Case StringInStr($sRow, '<rom name=')
					Local $rom_name = GetStringBetweenTwoDelimiters($sRow, '<rom name="', '"')
					Local $media_type = AppendToNonEmpty(GetStringBetweenTwoDelimiters($sRow, '1of', ')'), '1 of ')
					Local $file_type = ''
					; get the file type after the "."
					If StringInStr($rom_name, '.') Then
						$file_type = StringSplit($rom_name, '.', $STR_ENTIRESPLIT + $STR_NOCOUNT)
						$file_type = $file_type[UBound($file_type)-1]
					EndIf
					Local $size = GetStringBetweenTwoDelimiters($sRow, 'size="', '"')
					Local $crc = GetStringBetweenTwoDelimiters($sRow, 'crc="', '"')
					Local $md5 = GetStringBetweenTwoDelimiters($sRow, 'md5="', '"')
					Local $sha1 = GetStringBetweenTwoDelimiters($sRow, 'sha1="', '"')
					Local $status = GetStringBetweenTwoDelimiters($sRow, 'status="', '"')
					; rom_name can have multiple rows for givin title
					_ArrayAdd($aRomName, $rom_name & ':' & $media_type & ':' & $file_type & ':' & $size & ':' & $crc & ':' & $md5 & ':' & $sha1 & ':' & $status, $ARRAYFILL_FORCE_SINGLEITEM)

				; check end of single game title
				Case StringInStr($sRow, '</game>')
					$isEndOfGameTitle = True

				; End of File
				Case StringInStr($sRow, '</datafile>')
					; do nothing

				; log if row didn't match any above filters
				Case Else
					Local $sMoreInfo = 'WARN: unknown row data: >' & $sRow & '<'
					ConsoleLog($sMoreInfo)

			EndSelect

			; save data after all rows for a title have been parsed.
			If $isEndOfGameTitle Then
				For $sRom In $aRomName
					Local $aValue = StringSplit($sRom, ':', $STR_ENTIRESPLIT + $STR_NOCOUNT)
					$aDBKeyValue[$iRom_Name][$iDbValue]   = $aValue[0]
					$aDBKeyValue[$iMedia_Type][$iDbValue] = $aValue[1]
					$aDBKeyValue[$iFile_type][$iDbValue]  = $aValue[2]
					$aDBKeyValue[$iSize][$iDbValue] 	  = $aValue[3]
					$aDBKeyValue[$iCrc][$iDbValue] 		  = $aValue[4]
					$aDBKeyValue[$iMd5][$iDbValue] 		  = $aValue[5]
					$aDBKeyValue[$iSha1][$iDbValue] 	  = $aValue[6]
					$aDBKeyValue[$iStatus][$iDbValue]     = $aValue[7]
					InsertToDB($hDB, $aDBKeyValue)
				Next

				; reset rom_name array
				Local $aRomName[0]

				; reset values for next game title
				For $iIndex = $iDBGameDataStart To $iDBGameDataEnd
					$aDBKeyValue[$iIndex][$iDbValue] = ""
				Next
			EndIf
		Next
	Next

	;_ArrayDisplay($aDBKeyValue, "Results from the query")

	StopDB($hDB, true, true)
EndFunc

; *************************************************
;
; *************************************************
Func RegexOnResourceFile($sValue, $sReg1, $aFile, $sReg2)
	;ConsoleLog('================')
	;ConsoleLog(UBound($aFile))
	;ConsoleLog($aFile)

	For $f = 1 to UBound($aFile) - 1
		Local $aRow = StringSplit($aFile[$f], '|', $STR_NOCOUNT)

		For $r = 1 to UBound($aRow) - 1
			If $sReg1 <> '' And  $sReg2 <> '' And StringRegExp($sValue, $sReg1 & $aRow[$r] & $sReg2) Then
				Return $aRow[1]
			ElseIf $sReg1 = '' And  $sReg2 <> '' And StringRegExp($sValue, $aRow[$r] & $sReg2) Then
				Return $aRow[1]
			ElseIf $sReg1 <> '' And  $sReg2 = '' And StringRegExp($sValue, $sReg1 & $aRow[$r]) Then
				Return $aRow[1]
			EndIf
		Next
	Next

	;If StringRegExp($sValue, '^' & $aRow[$r] & '(-.*?|,\s.*?)$') Then Return $aRow[1]

	; nothing found
	Return ''
EndFunc

; *************************************************
;
; *************************************************
Func CheckResourceFile($string, $aFile)
	;ConsoleLog('================')
	;ConsoleLog(UBound($aFile))
	;ConsoleLog($aFile)

	For $f = 1 to UBound($aFile) - 1
		Local $aRow = StringSplit($aFile[$f], '|', $STR_NOCOUNT)

		For $r = 1 to UBound($aRow) - 1
			IF $string == $aRow[$r] And $string <> ''  And $aRow[$r] <> '' Then
				Return $aRow[1]
			EndIf
		Next

	Next

	; nothing found
	Return ''
EndFunc

; *************************************************
; Load resource files
; *************************************************
Func LoadResourceFile($sFile)
	Local $aFileArray = ArrayOfFileContents($sFile)
	Local $aNewArray[0]

	For $i = 1 to UBound($aFileArray) - 1
		Local $sFileRow = StringSplit($aFileArray[$i], ';', $STR_NOCOUNT)[1]
		_ArrayAdd($aNewArray, Formatting($sFileRow))
	Next

	Return $aNewArray
EndFunc

; *************************************************
; Check for empty string before appending value
; *************************************************
Func AppendToNonEmpty($string, $sAppend)
	If $string == 0 Or $string == '' Then
		Return ''
	Else
		Return $sAppend & $string
	EndIf
EndFunc

; *************************************************
;
; *************************************************
Func GetStringBetweenTwoDelimiters($string, $sDelLeft, $sDelRight)
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
	;date","publisher","region","country","rev","proto","video","file_type","size","crc","md5","sha1","cloneof","description","release_name","rom_name","status","notes","header_name","header_description","header_clrmamepro","header_romcenter_plugin","header_version","header_date","header_author","header_url

	;_SQLite_Exec($hDatabase, 'INSERT INTO Roms VALUES ("' & $title & '","' & $date & '","' & _
	;_SQLite_Exec($hDB, 'INSERT INTO Roms VALUES (' & $title & '","' & ');')

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
	;_SQLite_Exec($hDB, 'CREATE TABLE Roms (title, date, publisher, region, country, language, rev, proto, video, file_type, size, crc, md5, sha1, cloneof, description, release_name, rom_name, status, notes, header_name, header_description, header_clrmamepro, header_romcenter_plugin, header_version, header_date, header_author, header_url);')
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

	; Remove "Rev #" from end of game title
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

	; replce illegal character
	If StringInStr($string, '/') Then $string = StringReplace($string, '/', ' -')
	If StringInStr($string, '\') Then $string = StringReplace($string, '\', ' -')
	If StringInStr($string, '?') Then $string = StringReplace($string, '?', ' -')
	If StringInStr($string, ':') Then $string = StringReplace($string, ':', ' -')
	If StringInStr($string, '*') Then $string = StringReplace($string, '*', ' -')
	If StringInStr($string, '"') Then $string = StringReplace($string, '"', ' -')
	If StringInStr($string, '<') Then $string = StringReplace($string, '<', ' -')
	If StringInStr($string, '>') Then $string = StringReplace($string, '>', ' -')
	If StringInStr($string, '|') Then $string = StringReplace($string, '|', ' -')

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
