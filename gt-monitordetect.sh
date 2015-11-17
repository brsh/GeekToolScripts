#!/bin/bash

#Just a quick detection
#See if one or the other of the non-laptop monitors are connected
#and enable or disable the GeekTool scripts as appropriate

#Note:	Expects the gt-monitorXX-on and -off scpt files
#	AND the appropriate groups defined in GeekTool.

ScriptLoc="$(dirname $0)"

#Simplest: use the serial number of the monitor (see the system_profile SPDisplaysDataType for info)
LeftMonitor="0VW5M24D08US"
RightMonitor="U828K0CPBFCS"

retval=$(system_profiler SPDisplaysDataType | awk ' BEGIN {FS=":"}; /'${RightMonitor}'/ { x="RIGHT" }; /'${LeftMonitor}'/ { y="LEFT" }; END { print x";"y } ')

if [[ "${retval}" =~ "LEFT" ]]; then
        osascript "${ScriptLoc}/gt-monitorleft-on.scpt"
else
        osascript "${ScriptLoc}/gt-monitorleft-off.scpt"
fi

if [[ ${retval} == *RIGHT* ]]; then
	osascript "${ScriptLoc}/gt-monitorright-on.scpt"
else
	osascript "${ScriptLoc}/gt-monitorright-off.scpt"
fi

