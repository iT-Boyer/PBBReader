on run
do shell script "open -n /Applications/mpv.app"
tell application "mpv" to activate
end run

on open theFiles
repeat with theFile in theFiles

end repeat
do shell script "open -na /Applications/mpv.app " & quote & (POSIX path of theFiles) & quote
tell application "mpv" to activate
end open

-------
-- on run
-- do shell script "open -n /Applications/mpv.app"
-- tell application "mpv" to activate
-- end run
-- on open theFiles
-- display dialog theFiles
-- repeat with theFile in theFiles
-- end repeat
-- set a to "/Users/admin/Library/Developer/Xcode/DerivedData/SISpeciesNotes-cubrzszeqsvgzoaqcqifypiwtzus/Build/Products/Debug/ScaryBugsMac.app/Contents/Resources/BigBuck.m4v"
-- log "a:" & a
-- set b to POSIX file a as string
--without as string the result is a file reference
-- if exists file b then
-- delete file b
-- do shell script "open -na /Applications/mpv.app " & quote & (POSIX path of a) & quote
-- do shell script "open -na /Applications/mpv.app" & b
-- tell application "mpv" to activate
-- end if
-- end open