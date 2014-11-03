#!/bin/bash
. ~/scripts/geektool/lib/lib_colors.sh

function show_help {
	echo " "
	echo "Please enter the amount and total and bar width as:"
	echo "   ${0##*/} [options] amount [total] [width] "
	echo "        -r	Reverse the bar's order"
	echo "        -l	Label"
	echo "        -p	Label position (L, R, or LR)"
	echo "        -b	Background color"
	echo "        -n	Normal indicator color"
	echo "        -u	High indicator color"
	echo "        -t	High threshold (percent)"
	echo "        -o	Low indicator color"
	echo "        -w	Low threshold (percent)"
	echo " "
	echo "   Color Options: Black, Red, Yellow, Blue, Green, Purple, Cyan, White, Off"
	exit 0
}

function set_color {
	local retval=""
	local temphold=$(echo ${1} | tr '[:lower:]' '[:upper:]')
	case "${temphold}" in
		BLACK)
			retval="${Black}${On_Black}"
		;;
		RED)
			retval="${Red}${On_Red}"
		;;
		YELLOW)
			retval="${Yellow}${On_Yellow}"
		;;
		BLUE)
			retval="${Blue}${On_Blue}"
		;;
		GREEN)
			retval="${Green}${On_Green}"
		;;
		PURPLE)
			retval="${Purple}${On_Purple}"
		;;
		CYAN)
			retval="${Cyan}${On_Cyan}"
		;;
		WHITE)
			retval="${White}${On_White}"
		;;
		OFF)
			retval="${Color_Off}"
		;;
		*)
		retval="ERROR"
		;;
	esac
	echo "${retval}"
}

#Defaults
separator=" "

normColor=$(set_color "Yellow")
bgColor=$(set_color "Black")
highColor=""
lowColor=""

BarSize=20
Order="RL"			#RL = Right to Left; LR = Left to Right
TextLoc="LR"		#R = on the right; L = on the left; LR = both
Label=""

highThresh=0
lowThresh=0

OPTIND=1 # Reset is necessary if getopts was used previously in the script.  It is a good idea to make this local in a function.
while getopts ":hrl:p:n:b:u:t:o:w:" opt; do
	case "$opt" in
		h | \?) show_help
		;;
		r)	# order LR or RL
			Order="LR"
		;;
		l)	# Label (text)
			Label="${OPTARG}"
		;;
		p)	# Label Position (L, R, or LR)
			TempHold=$(echo "${OPTARG}" | tr '[:lower:]' '[:upper:]')
			if [ "${TempHold}" = "LR" ] || [ "${TempHold}" = "L" ] || [ "${TempHold}" = "R" ]; then
				TextLoc=${TempHold}
			fi
		;;
		n)	# Normal Color
			TempHold=$(set_color "${OPTARG}")
			if ! [ "${TempHold}" == "ERROR" ]; then
				normColor="${TempHold}"
			fi
		;;
		b)
			# Background color
			TempHold=$(set_color "${OPTARG}")
			if ! [ "${TempHold}" == "ERROR" ]; then
				bgColor="${TempHold}"
			fi
		;;
		u)	# High Color
			TempHold=$(set_color "${OPTARG}")
			if ! [ "${TempHold}" == "ERROR" ]; then
				highColor="${TempHold}"
			fi
		;;
		t)	# High Threshold
			if [ ${OPTARG} -gt 0 ] && [ ${OPTARG} -lt 100 ]; then
				highThresh=${OPTARG}
			fi
		;;
		o)	# Low Color
			TempHold=$(set_color "${OPTARG}")
			if ! [ "${TempHold}" == "ERROR" ]; then
				lowColor="${TempHold}"
			fi
		;;
		w)	# Low Threshold
			if [ ${OPTARG} -gt 0 ] && [ ${OPTARG} -lt 100 ]; then
				lowThresh=${OPTARG}
			fi			
		;;
	esac
done
unset TempHold
shift "$((OPTIND-1))" # Shift off the options and optional --.=1

if [[ ${#} -lt 1 ]]; then
	show_help
fi
if [[ ${2} && ${2-x} ]]; then
	tot=$2
fi
if [[ ${3} && ${3-x} ]]; then
	BarSize=$3
fi
if [[ ${5} && ${5-x} ]]; then
	Label=$5
fi

amt=$1

##Now some math...
PercUsed=$(( (100 * ${amt}) / ${tot} ))
BarUsed=$(( (${BarSize} * ${PercUsed}) /100 ))
BarUnUsed=$(( ${BarSize} - ${BarUsed} ))

##Create the bar
BarTextUsed=""
BarTextUnUsed=""

if ! [ ${BarUsed} = 0 ]; then 
	i=0
	while [[ $i -le ${BarUsed} ]]; do
		BarTextUsed="${BarTextUsed}${separator}"
		(( i = i + 1))
	done
else
	#The bar should have a 0% used indicator since UnUsed expects SOMETHING (>0) used
	BarTextUnUsed=${separator}
fi

if ! [ ${BarUnUsed} = 0 ]; then 
	i=1
	while [[ $i -le ${BarUnUsed} ]]; do
		BarTextUnUsed="${BarTextUnUsed}${separator}"
		(( i = i + 1 ))
	done
fi

##Set our colors (based on thresholds, if set)
unColor="${bgColor}"
usedColor="${normColor}"
if [ ${lowThresh} -gt 0 ] && [[ ${lowColor} && ${lowColor-x} ]]; then
	if [ ${PercUsed} -lt ${lowThresh} ]; then
		usedColor="${lowColor}"
	fi
fi
if [ ${highThresh} -gt 0 ] && [[ ${highColor} && ${highColor-x} ]]; then
	if [ ${PercUsed} -gt ${highThresh} ]; then
		usedColor="${highColor}"
	fi
fi

##Display the bar
if [[ ${Label} && ${Label-x} ]] && [[ ${TextLoc} =~ "L" ]]; then
	printf "${SubHead}${Label} "
fi
if [ "${Order}" = "RL" ]; then 
	printf "${usedColor}${BarTextUsed}${unColor}${BarTextUnUsed}${Color_Off}"
else
	printf "${unColor}${BarTextUnUsed}${usedColor}${BarTextUsed}${Color_Off}"
fi

if [[ ${Label} && ${Label-x} ]] && [[ ${TextLoc} =~ "R" ]]; then
	printf " ${SubHead}${Label}${Color_Off}"
fi
