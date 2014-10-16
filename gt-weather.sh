#!/bin/bash

####################
## Set Color Vars ##
####################

# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

## Local Settings
SubHead=${Yellow}
Text=${White}
Item=${BWhite}


function Conditions { 
	local retval=$(echo "${WeatherData}" | grep -A 4 "Updated" | tail +3 | head -1)
	printf "${retval}"
}

function Temp {
	local retval=$(echo "${WeatherData}" | grep -A 4 "Updated" | tail +4 | head -1 | sed "s/\..\ //")
	printf "${retval}"
}

function FeelsLike {
	local retval=$(echo "${WeatherData}" | grep -A 4 "Updated" | tail +4 | head -1 | sed "s/\..\ //")
	printf "Feels like ${retval}"
}

function ForeCast {
	local retval="$(printf "${SubHead}Today:${Text}\t"; echo "${WeatherDataMob}" | grep -v Night | grep -A2 --color=never "^$(date -j "+%A")" | head -3 | tail -1 | sed s/Winds/#/g | cut -d \# -f1 && printf "${SubHead}Tomorrow:${Text}\t"; echo "${WeatherDataMob}" | grep -v Night | grep -A2 --color=never "^$(date -j -v +1d "+%A")" | head -3 | tail -1 | sed s/Winds/#/g | cut -d \# -f1)"

	printf "${retval}"
}

function ForeCastFive {
	local alldata="$(echo "${WeatherDataMob}"  | grep -A1000 BestForecast | grep -v -E "haza|aler" | tr -s "\n" | tail +2 | grep -v -m 20 "$(date -j -v +5d +%A)" | sed s/Winds/#/g | cut -d \# -f1 | awk '{printf "%s", $0; $0=""; getline; print "\t" $0}')"
	local retval=$(echo "${alldata}" | sed -e "s/^$(date -j +%A)\ Night/Tonight${TAB}/" -e "s/^$(date -j +%A)/Today${TAB}/" -e "s/^$(date -j -v +1d +%A)/Tomorrow/" -e "s/Friday${TAB}/Friday${TAB}${TAB}/" -e "s/^/$(printf "${SubHead}")/" -e "s/${TAB}/$(printf "${Text}")${TAB}/")
	printf "${retval}"
}

function Quickie {
	local retval=$(echo "${WeatherDataRaw}" | grep "is forecast" | cut -d \" -f4 | sed -e :a -e 's/<[^>]*>//g;/</N;//ba')
	printf "${retval}"
}

function MobileQuery {
		WeatherDataMobRaw=$(curl -s ${mobloc})
		WeatherDataMob=$(echo "${WeatherDataMobRaw}" | textutil -convert txt -stdin -stdout -format html)
}

function Set-Loc {
	#Default is RWC
	#But let's allow for others
	case "${1}" in
		SF )
			loc="http://www.wunderground.com/cgi-bin/findweather/hdfForecast?query=37.775%2C-122.419&sp=KCASANFR298"
			mobloc="http://m.wund.com/cgi-bin/findweather/getForecast?brand=mobile&query=37.775%2C-122.419&sp=KCASANFR298"
		;;
		DAY* )
			loc="http://www.wunderground.com/cgi-bin/findweather/hdfForecast?query=39.740%2C-84.076&sp=KXDIOHBE1"
			mobloc="http://m.wund.com/cgi-bin/findweather/getForecast?brand=mobile&query=39.740%2C-84.076&sp=KXDIOHBE1"
		;;	
		* )
			#Default is RWC
			loc="http://www.wunderground.com/cgi-bin/findweather/hdfForecast?query=37.488%2C-122.214&sp=MRWCC1"
			mobloc="http://m.wund.com/cgi-bin/findweather/getForecast?brand=mobile&query=37.488%2C-122.214&sp=MRWCC1"
		;;
	esac
}

if [ -z "$1" ]; then
	echo " "
	echo "Please provide either a function or a location and a function:"
	echo "  ./gt-weather.sh Temp"
	echo "  ./gt-weather.sh SF Temp"
	echo " "
	echo "Functions: Conditions, Temperature, FeelsLike, Forecast, FiveDay, Quickie, Full"
	echo "           (you only need the first 3 characters - or Q for quickie)"
	echo " "
	echo "Locations: RWC, SF, Dayton"
	exit 0
elif [ -z "$2" ]; then
	Where="RWC"
	What=$(echo "$1" | tr '[:lower:]' '[:upper:]')
else
	Where=$(echo "$1" | tr '[:lower:]' '[:upper:]')
	What=$(echo "$2" | tr '[:lower:]' '[:upper:]')
fi

Set-Loc ${Where}

TAB=$'\t'

case "${What}" in
	FOR* | FIV*)
		MobileQuery
	;;
	*)
		WeatherDataRaw=$(curl -s ${loc})
		WeatherData=$(echo "${WeatherDataRaw}" | textutil -convert txt -stdin -stdout -format html)
	;;
esac

case "${What}" in
	CON* )
		Conditions
	;;
	
	TEM*)
		Temp
	;;
	FEE*)
		FeelsLike
	;;
	FOR*)
		ForeCast
	;;
	FIV* )
		blah=$(echo "$(ForeCastFive)" | sed -e "s/${TAB}/\ /g" | tr -s " ")
		printf "${blah}"
	;;
	Q* )
		Quickie
	;;
	FU*)
		MobileQuery
		printf "${SubHead}Location${Text}\t${Where}"
		printf "\n"
		printf "${SubHead}Temperature${Text}\t$(Temp) (${SubHead}feels like${Text} $(FeelsLike))"
		printf "\n"
		printf "${SubHead}Conditions${Text}\t$(Conditions)"
		printf "\n"
		printf "${SubHead}Summary${Text}\t\t$(Quickie)"
		printf "\n"
		ForeCastFive
		printf "\n"
	;;
esac



