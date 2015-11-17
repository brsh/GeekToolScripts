--script to turn the right monitor groups on
tell application "GeekTool Helper"

	set leftmonitorgroup to group "Left-Monitor"
	set leftmonitoroff to group "Left-Monitor-Off"

	set visible of leftmonitorgroup to false
	set visible of leftmonitoroff to true

end tell
