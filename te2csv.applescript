--
-- te2csv
-- 
-- Script to export TextExpander V5 groups to CSV files
-- Basic script by Jeff from Smile Software (http://smilesoftware.com)
-- Enhancements to output valid CSVs by halloleo (http://blog.halloleo.net)

-- updated 2018-07-05 by derickfay for use with Alfred
--

tell application "TextExpander"
	set groupNames to name of groups
end tell
tell application "Finder"
	set listResult to choose from list groupNames with title "Groups" with prompt "Please pick group(s) to export." multiple selections allowed yes empty selection allowed no
	set folderResult to choose folder with prompt "Please choose the folder into which to write the exported groups, or make one using the New Folder button."
end tell
set lineCmdFolder to POSIX path of ((path to me as text) & "::")
set lineCmd to "python " & lineCmdFolder & "te2csv_encoder.py"

tell application "TextExpander"
	repeat with aListResult in listResult
		set groupName to aListResult as string
		log "Exporting group: " & groupName
		set fileHandle to open for access ((folderResult as rich text) & groupName & ".csv") with write permission
		set eof fileHandle to 0
		write ((ASCII character 239) & (ASCII character 187) & (ASCII character 191)) to fileHandle
		set aGroup to item 1 of (groups whose name is equal to groupName)
		log "About to iterate snippets"
		repeat with aSnippet in snippets of aGroup
			tell aSnippet
				try
					set thisLine to do shell script lineCmd & " \"" & name & " \"" & abbreviation & "\" " & " \"" & plain text expansion & "\" "
				on error errMessage number errNumber
					set thisLine to "# Error" & errMessage & "for " & name & "/" & abbreviation & " / " & plain text expansion
				end try
				set thisLine to thisLine & "
"
				write thisLine to fileHandle as «class utf8»
				log "Wrote: " & thisLine
			end tell
		end repeat
		log "Completed iterating snippets"
		close access fileHandle
		log "Closed export file"
	end repeat
end tell
tell application "Finder"
	set ans to display dialog "Export to " & (POSIX path of folderResult) & " completed." buttons {"Open export folder & close", "Close"} default button "Close"
	if button returned of ans = "Open export folder & close" then
		open folderResult
		activate
	end if
end tell
