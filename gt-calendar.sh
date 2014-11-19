#!/bin/bash
ScriptLoc="$(dirname $0)/lib"
source ${ScriptLoc}/lib_colors.sh

Background=${On_Black}
Foreground=${White}
CurrentText=${Yellow}
MonthCurrent=${Color_Off}
MonthNot=${Yellow}

function rtrim() {
	local var=$@
	var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
	echo -n "$var"
}

function ltrim() {
	local var=$@
	var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
	echo -n "$var"
}

function trim() {
	local var=$@
	var=$(ltrim "${var}")
	var=$(rtrim "${var}")
	echo -n "$var"
}

WEEK="${Color_Off}${Background}Su Mo Tu We Th Fr Sa${Color_Off}\n"
PREVOut=$(trim "$(cal $(date -j -v -2m "+%m %Y") | grep .. | tail -1 )")
PREV=$(trim "$(cal $(date -j -v -1m "+%m %Y") | grep .. | tail +3 )")
CURR=$(trim "$(cal | tail -n6)")
NEXT=$(trim "$(cal $(date -j -v +1m "+%m %Y") | grep .. | tail +3 )")
NEXTOut=$(trim "$(cal $(date -j -v +2m "+%m %Y") | grep -v "[A-Za-z]" | head -n 1)")
LINE=$((($(date +%e)/7)+5))

#Display the Current Date
printf "${Foreground}"
date +"%a, %b. %e" | sed -Ee 's/([^1]1)$/\1st/' -Ee 's/([^1]2)$/\1nd/' -Ee 's/([^1]3)$/\1rd/' -Ee 's/([0-9])$/\1th/' -e 's/  / /g' 

#Display the "week day" header
printf "${WEEK}"

#Display the calendars
printf "${Black}${PREVOut}  ${Yellow}${PREV}  ${Color_Off}${CURR}  ${Yellow}${NEXT}  ${Black}${NEXTOut}" | sed -e "$LINE,$(($LINE+2)) s/ $(date +%e) / $(printf "${Background}")$(date +%e)$(printf "${Color_Off}${Foreground}") /"

#Display the "week day" footer
printf "${WEEK}"
