#!/bin/bash
ScriptLoc="$(dirname $0)/lib"
source ${ScriptLoc}/lib_colors.sh

cBackground=${On_Black}
cForeground=${White}
cDimmest=${Black}
cDimmer=${Yellow}
cCurrent=${Color_Off}
cHighlight=${cBackground}

function trim() {
	local var=$@
	var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
	var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
	echo -n "$var"
}

WEEK="${Color_Off}${cBackground}Su Mo Tu We Th Fr Sa${Color_Off}\n"
PREVOut=$(trim "$(cal $(date -j -v -2m "+%m %Y") | grep .. | tail -1 )")
PREV=$(trim "$(cal $(date -j -v -1m "+%m %Y") | grep .. | tail +3)")
CURR=$(trim "$(cal | tail -n6)")
NEXT=$(trim "$(cal $(date -j -v +1m "+%m %Y") | grep .. | tail +3 )")
NEXTOut=$(trim "$(cal $(date -j -v +2m "+%m %Y") | grep -v "[A-Za-z]" | head -n 1)")
LINE=$((($(date +%e)/7)+5))

#Display the Current Date
printf "${cForeground}"
date +"%a, %b. %e" | sed -Ee 's/([^1]1)$/\1st/' -Ee 's/([^1]2)$/\1nd/' -Ee 's/([^1]3)$/\1rd/' -Ee 's/([0-9])$/\1th/' -e 's/  / /g' 

#Display the "week day" header
printf "${WEEK}"

#Display the calendars
printf "${cDimmest}${PREVOut}${Color_Off}  ${cDimmer}${PREV}${Color_Off}  ${cCurrent}${CURR}${Color_Off}  ${cDimmer}${NEXT}${Color_Off}  ${cDimmest}${NEXTOut}${Color_Off}" | sed -e "$LINE,$(($LINE+2)) s/ $(date +%e) / $(printf "${cHighlight}")$(date +%e)$(printf "${Color_Off}${cForeground}") /"

#Display the "week day" footer
printf "${WEEK}"
