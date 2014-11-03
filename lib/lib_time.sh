#!/bin/bash
##### Library of Time Functions
## source this file to access it's functions...

function LongOutTime {
	## Argument 1: the seconds to convert
	## Argument 2: the granularity: D - day; H - hour; M - minute; S - seconds [optional]
	local timeused=${1%%.*}
	local daysused=0
	local hoursused=0
	local minutesused=0
	local secondsused=0

	## Now to add a filter for how granular to be...
	## Day Hour Minute Seconds... all proceed alphabetically
	## So we can use their Ascii values to help filter!
	## First, get if there's a display filter switch
	##     (we'll use Z otherwise... it's above them all)
	local switches=${2:-Z}
	
	## Now, let's make it capitalized for convenience
	switches=$(echo ${switches:0:1} | tr '[:lower:]' '[:upper:]')

	## And now, get the ascii value
	## D=68; H=72; M=77; S=83; (and Z=90)
	switches=$(printf '%d' "'$switches")

	#break it up into human readable time
	if [[ ${timeused} && ${timeused-x} ]]; then
		if (( timeused > 86400 )); then
			((
				daysused=timeused/86400,
				hoursused=timeused/3600-daysused*24,
				minutesused=timeused/60-hoursused*60-daysused*60*24,
				secondsused=timeused-minutesused*60-hoursused*3600-daysused*3600*24
			))
		elif (( timeused < 3600 )); then
			((
				minutesused=timeused/60,
				secondsused=timeused-minutesused*60
			))
		elif (( timeused < 86400 )); then
			((
				hoursused=timeused/3600,
				minutesused=timeused/60-hoursused*60,
				secondsused=timeused-minutesused*60-hoursused*3600
			))
		fi

		local sDay="days"
		local sHour="hours"
		local sMinute="minutes"
		local sSecond="seconds"
		
		if [ ${daysused} -eq 1 ]; then sDay="day"; fi
		if [ ${hoursused} -eq 1 ]; then sHour="hour"; fi
		if [ ${minutesused} -eq 1 ]; then sMinute="minute"; fi
		if [ ${secondsused} -eq 1 ]; then sSecond="second"; fi
		
		#color and display
		if [ ${switches} -gt 67 ]; then retval=${retval}"${daysused} ${sDay}"; fi
       	if [ ${switches} -gt 71 ]; then retval=${retval}"  ${hoursused} ${sHour}"; fi
		if [ ${switches} -gt 76 ]; then retval=${retval}"  $(echo ${minutesused} | sed -e :a -e 's/^.\{1,1\}$/0&/;ta' ) ${sMinute}"; fi
		if [ ${switches} -gt 82 ]; then retval=${retval}"  $(echo ${secondsused} | sed -e :a -e 's/^.\{1,1\}$/0&/;ta' ) ${sSecond}"; fi
		printf "${retval}" 
	fi
}

function date2secs { 
	date -j -f "%m/%d/%Y-%H-%M" "$1" +%s
}

function dateDiff {
    dte1=$1
    dte2=$2
    diffSec=$((dte2-dte1))
    if ((diffSec < 0)); then abs=-1; else abs=1; fi
    echo $((diffSec*abs))
}
