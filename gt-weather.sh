#!/bin/bash
ScriptLoc="$(dirname $0)/lib"
source ${ScriptLoc}/lib_colors.sh

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
	SU*)
		SunNMoon
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



