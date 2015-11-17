--script to turn the right monitor groups on
tell application "GeekTool Helper"

	set rightmonitorgroup to group "Right-Monitor"
	set rightmonitoroff to group "Right-Monitor-Off"

	set visible of rightmonitorgroup to true
	set visible of rightmonitoroff to false

end tell
