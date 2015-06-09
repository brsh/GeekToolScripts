tell application "System Events"
set myList to (name of every process)
end tell
if myList contains "iTunes" then
set player to "iTunes"
else if myList contains "Spotify" then
set player to "Spotify"
else if myList contains "Vox" then
set player to "Vox"
else
return
end if
if player is "iTunes" or player is "Spotify" then
using terms from application "iTunes"
tell application player
if player state is stopped then
return
end if
set trackname to name of current track
set artistname to artist of current track
set albumname to album of current track
set trackduration to duration of current track
if player state is playing then
set state to 1
else if player state is paused then
set state to 0
else
set state to -1
end if
end tell
end using terms from
else if player is "Vox" then
tell application "VOX"
set trackname to track
set artistname to artist
set albumname to album
set state to player state

end tell
else
return
end if
if state is 1 then
set pauseIcon to ""
else if state is 0 then
set pauseIcon to "\n❙❙"
else
set pauseIcon to ""
end if

if artistname = missing value then
set artistname to ""
set thespliticon to ""
else
set thespliticon to "\n"
end if
if albumname = missing value then
set albumname to ""
set thehaakje1 to ""
set thehaakje2 to ""
else
set thehaakje1 to " ("
set thehaakje2 to ")"
end if

return trackname & thespliticon & artistname & "\n" & albumname & pauseIcon