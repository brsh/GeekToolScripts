#!/bin/bash

ScriptLoc="$(dirname $0)"
source ${ScriptLoc}/lib/lib_colors.sh

osascript ${ScriptLoc}/gt-musictrackinfo.scpt | awk ' 
	BEGIN { off="'${Color_Off}'"; cYellow="'${Yellow}'"; cWhite="'${White}'" };
	NR==1 {printf cYellow"%s\n"off, $0};
	NR==2 {printf cWhite"%s\n"off, $0};
	NR==3 {printf cWhite"%s\n"off, $0};
	NR==4 {printf off"%s"off, $0};
	END {printf "  "}
	'
