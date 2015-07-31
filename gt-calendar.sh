#!/bin/bash
ScriptLoc="$(dirname $0)/lib"
source ${ScriptLoc}/lib_colors.sh

cBackground=${On_Black}
cForeground=${White}
cDimmest=${Black}
cDimmer=${Yellow}
cCurrent=${Color_Off}
cHighlight=${BWhite}${cBackground}

function trim() {
	local var=$@
	var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
	var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
	echo -n "$var"
}

#Set our Variables
WEEK="${Color_Off}${cBackground}Su Mo Tu We Th Fr Sa${Color_Off}\n"
PAST=$(trim "$(cal $(date -j -v -2m "+%m %Y") | grep .. | tail -1 )")
PREV=$(trim "$(cal $(date -j -v -1m "+%m %Y") | grep .. | tail +3)")
CURR=$(trim "$(cal $(date -j -v +0m "+%m %Y") | tail -n6)")
NEXT=$(trim "$(cal $(date -j -v +1m "+%m %Y") | grep .. | tail +3 )")
FUTR=$(trim "$(cal $(date -j -v +2m "+%m %Y") | grep -v "[A-Za-z]" | head -n 1)")

#Adjust each depending on how long the "last" week is
#("last" is relative since PAST and FUTR are partials)
#Otherwise, when a month that ends on Sat, the next would start on the same line
#A week should be 20 chars (2 chars per day [14], plus the spaces between [6])
#Except for the FUTR partial, which has a single digit in column 1
#Either adds space(s) and/or NewLine around each month
blah=${PAST##*$'\n'}
if (( ${#blah} >= 19 )); then
	PAST=""
else
	PAST="${PAST} "
fi

blah=${PREV##*$'\n'}
if (( ${#blah} == 20 )); then
	PREV=" ${PREV}\n"
else
	PREV=" ${PREV} "
fi

blah=${CURR##*$'\n'}
if (( ${#blah} == 20 )); then
	CURR=" ${CURR}\n"
else
	CURR=" ${CURR} "
fi

blah=${NEXT##*$'\n'}
if (( ${#blah} == 20 )); then
	NEXT=" ${NEXT}\n"
else
	NEXT=" ${NEXT} "
fi

blah=${FUTR##*$'\n'}
if (( ${#blah} >= 19 )); then
	FUTR=""
else
	FUTR=" ${FUTR}\n"
fi

#Hightlight the current date
#Seems to work for everything...
#...except if the 1st is on Saturday. Giving up.
FText=$(date -j +%e)
RText=$(printf "${cHighlight}")${FText}$(printf "${Color_Off}${cForeground}")
CURR=$(echo "${CURR}" | sed -e "s/ ${FText} / ${RText} /" -e "s/ ${FText}$/ ${RText}/" -e "s/^${FText} /${RText} /")

unset blah FText RText

#Display the Current Date
printf "${cForeground}"
date +"%a, %b. %e" | sed -Ee 's/([^1]1)$/\1st/' -Ee 's/([^1]2)$/\1nd/' -Ee 's/([^1]3)$/\1rd/' -Ee 's/([0-9])$/\1th/' -e 's/  / /g' 

#Display the "week day" header
printf "${WEEK}"

#Display the calendars
printf "${cDimmest}${PAST}${Color_Off}"
printf "${cDimmer}${PREV}${Color_Off}"
printf "${cCurrent}${CURR}${Color_Off}"
printf "${cDimmer}${NEXT}${Color_Off}"
printf "${cDimmest}${FUTR}${Color_Off}"

#Display the "week day" footer
printf "${WEEK}"
