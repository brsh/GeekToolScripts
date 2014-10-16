#!/bin/bash
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

Color_Off='\e[0m'       # Text Reset

separator=" "
usedColor="${Yellow}${On_Yellow}"
unColor="${White}${On_White}"
BarSize=20
Order="LR"			#RL = Right to Left
TextLoc="O"			#R = on the right; L = on the left; O = off

if [ $# -lt 2 ]; then
	echo "Please enter the amount and total and bar width as:"
	echo "     progbar.sh amt tot [width]"
	exit
elif [[ ${3} && ${3-x} ]]; then
	BarSize=$3
fi
amt=$1
tot=$2

PercUsed=$(( (100 * ${amt}) / ${tot} ))
BarUsed=$(( (${BarSize} * ${PercUsed}) /100 ))
BarUnUsed=$(( ${BarSize} - ${BarUsed} ))

BarTextUsed=""
BarTextUnUsed=""

if ! [ ${BarUsed} = 0 ]; then 
	i=0
	while [[ $i -le ${BarUsed} ]]; do
		BarTextUsed="${BarTextUsed}${separator}"
		(( i = i + 1))
	done
else
	BarTextUnUsed=${separator}
fi

if ! [ ${BarUnUsed} = 0 ]; then 
	i=1
	while [[ $i -le ${BarUnUsed} ]]; do
		BarTextUnUsed="${BarTextUnUsed}${separator}"
		(( i = i + 1 ))
	done
fi

if [ "${TextLoc}" = "L" ]; then
	printf "${PercUsed}%% Used "
fi
if [ "${Order}" = "RL" ]; then 
	printf "${usedColor}${BarTextUsed}${unColor}${BarTextUnUsed}${Color_Off}"
else
	printf "${unColor}${BarTextUnUsed}${usedColor}${BarTextUsed}${Color_Off}"
fi
if [ "${TextLoc}" = "R" ]; then
	printf " ${PercUsed}%% Used "
fi
