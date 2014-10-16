#!/bin/bash

Yellow='\e[0;33m'       # Yellow
White='\e[0;37m'        # White
Green='\e[0;32m'        # Green
BBlack='\e[1;30m'       # Black
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_White='\e[47m'       # White
Color_Off='\e[0m'       # Text Reset

Background=${On_Black}
Foreground=${White}
CurrentText=${Yellow}
MonthCurrent=${Color_Off}
MonthNot=${Yellow}

WEEK="Su Mo Tu We Th Fr Sa"
PREVOut=$(cal $(date -j -v -2m "+%m %Y") | grep .. | tail -1 )
PREV=$(cal $(date -j -v -1m "+%m %Y") | grep .. | tail +3 )
CURR=$(cal | tail -n6)
NEXT=$(cal $(date -j -v +1m "+%m %Y") | grep .. | tail +3 )
NEXTOut=$(cal $(date -j -v +2m "+%m %Y") | grep .. | tail +3 )
LINE=$((($(date +%e)/7)+5))

printf "${Foreground}"
echo "$(date +"%a, %b %e" | sed -E 's/([^1]1)$/\1st/' | sed -E 's/([^1]2)$/\1nd/' | sed -E 's/([^1]3)$/\1rd/' | sed -E 's/([0-9])$/\1th/' | sed -e "s/\ \ /\ /" -e "s/$/\,\ $(date -j +%Y/)")" | fmt -c 21 21
printf " ${Color_Off}${Background}$WEEK${Color_Off}${MonthNot}\n" 

echo ${PREVOut}${PREV}$CURR$NEXT${NEXTOut} | sed -e s'/$/ /g' -e s'/ /  /g' -e s'/\([^0-9][0-9][^0-9]\)/ \1/g' -e s'/  / /g' -e s"/\(.\{21\}\)/\1#/g" | tr -s '#' '\n' | head -n 14| sed -e s'/^/ /g' -e "5,5 s/ 1 /$(printf "${MonthCurrent}") 1 /" -e "9,9 s/ 1 / $(printf "${MonthNot}")1 /" -e "$LINE,$(($LINE+2)) s/ $(date +%e) / $(printf "${Background}")$(date +%e)$(printf "${Color_Off}${Foreground}") /" 


printf " ${Color_Off}${Background}${WEEK}${Color_Off} "
