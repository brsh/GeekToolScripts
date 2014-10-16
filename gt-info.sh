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
Heading=${Yellow}${On_Black}
Text=${White}
SubHead=${Yellow}
Item=${BWhite}

#ip address
function get-net {
local retval
local ipaddr
local masktemp
local netcalc
local defgateway
local SSID
local DHCPServer
local DHCPLeaseExpire=""
local DNSServer
local ConType
local MACAddr
local WiFiDeets=""
local ifconfig=""
local ipconfig=""

printf "${Heading}Network Information                                                                                                                      ${Color_Off}\n"
for INTs in $(ifconfig -l); do
	if [ "${INTs:0:2}" = "en" ]; then
		retval=""
		ipaddr=""
		masktemp=""
		netcalc=""
		defgateway=""
		SSID=""
		DHCPServer=""
		DHCPLeaseExpires=""
		DNSServer=""
		ConType=""
		MACAddr=""
		WifiDeets=""
		ifconfig=""
		ipconfig=""
		
		ifconfig=$(ifconfig ${INTs})
		ipaddr=$(echo "${ifconfig}" | awk '/inet[[:space:]]/ {print $2 }')
		masktemp=$(echo "${ifconfig}" | awk '/inet[[:space:]]/ {print $4 }')
		
		if [ ${#masktemp} -eq 10 ]; then
			netcalc="$((0x${masktemp:2:2} / 0x1)).$((0x${masktemp:4:2} / 0x1)).$((0x${masktemp:6:2} / 0x1)).$((0x${masktemp:8:2} / 0x1))"
		else
			netcalc="n/a"
		fi
		defgateway=$(netstat -nr | grep ${INTs} | grep default | awk '{printf("%s,",$2)}' | sed 's/,\s*$//')

		ConType=$(networksetup -listallhardwareports | grep -C1 ${INTs} | head -1 | awk ' { $1=$2=""; print }' | sed -e s/\ \ //g)
		if [ "${ConType}" = "Wi-Fi" ]; then
			#SSID=$(printf "`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | grep -i " ssid" | awk '{print $2, $3, $4, $5, $6}'`\n" | sed "s/\ //g")
			SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | grep -i " ssid" | cut -d ":" -f 2 | sed "s/^\ //")
			if ! [[ "${SSID}" && "${SSID-x}" ]]; then
				SSID="n/a"
			else
				WiFiDeets="$(system_profiler SPAirPortDataType | grep -A10 "Current Network Information" | grep "PHY" | cut -d ':' -f 2 | sed "s/^\ //")"
			fi
		fi
		
		ipconfig=$(ipconfig getpacket ${INTs})		
		DHCPServer=$(echo "${ipconfig}" | grep -E "server_identifier|siaddr" | grep -v 0.0.0.0 | tail -1 | cut -d ':' -f 2 | sed -e 's/^\ //g')
		if [[ "${DHCPServer}" && "${DHCPServer-x}" ]]; then
			DHCPLeaseExpires=$(date -r $(echo $(date +%s) + $(( $(echo "${ipconfig}" | awk '/rebinding_t2_time_value[[:space:]]/ { $1=$2=""; print }') / 0x1 )) | bc) +'%a %m/%d/%Y %_I:%M%p')
		fi
		DNSServer=$(echo "${ipconfig}" | awk '/domain_name_server[[:space:]]/ { $1=$2=""; print }' | sed -e s/\ \ //g | sed -e s/[\{\}]//g)
		
		if [[ "${ipaddr}" && "${ipaddr-x}" ]]; then
			printf " ${SubHead}${ConType} - interface ${INTs}${Color_Off}\n"
			printf "   ${Item}IP Address:${Color_Off}\t${Text}${ipaddr} / ${netcalc}${Color_Off}\n"
			printf "   ${Item}DHCP Server:${Color_Off}\t${Text}${DHCPServer} (${Item}Lease Expires:${Text} ${DHCPLeaseExpires})${ColorOff}\n"
			printf "   ${Item}Def Gateway:${Color_Off}\t${Text}${defgateway}${Color_Off}\n"
			printf "   ${Item}DNS Servers:${Color_Off}\t${Text}${DNSServer}${Color_Off}\n"
			if [ "${ConType}" = "Wi-Fi" ]; then
				printf "   ${Item}WiFi SSID:${Color_Off}\t${Text}${SSID} - ${WiFiDeets}${Color_Off}\n"
			fi
			printf "\n"
		fi
	retval=""
	fi
done
}

function get-disk {
	printf "${Heading}Disk Information                                                                                                                      ${Color_Off}\n"
	printf "${SubHead}"
	echo "FileSystem Size Used Avail Used Mounted On" | awk '{printf "  %-20s %6s %6s %6s %6s  %s %s\n",  $1,$2,$4,$3,$5,$6,$7 }'
	printf "${Text}"
	df -H -T nfs,hfs | awk '{printf "  %-20s %6s %6s %6s %6s  %s\n",  $1,$2,$4,$3,$5,$9 }' | tail +2
	printf "${Color_Off}"
	printf "\n"
}

function get-users {
	printf "${Heading}Active User Summary                                                                                                                      ${Color_Off}\n"
	printf "${SubHead}"
	echo 'UserName Terminal Time Logged In' | awk '{printf "  %-16s   %-15s %s %s %s\n", $1, $2, $3, $4, $5;}'
	printf "${Text}"
	who | awk '{ printf "    %-16s %-15s %s %s %s\n", $1, $2, $3, $4, $5 ; }'
	printf "${Color_Off}"
	printf "\n"
}

function get_uptime() {
	local retval=""
    local uptime

	local boottime=$(sysctl -n kern.boottime | awk '{print $4}' | sed 's/,//g')
	local unixtime=$(date +%s)
	uptime=$((${unixtime} - ${boottime}))

	retval="$(LongOutTime ${uptime} m)"
	printf "${Item}Up for:${Color_Off} \t${Text}${retval}${Color_Off}"
}

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

function get-screen {
	local retval=""
	#retval=$(system_profiler SPDisplaysDataType | grep "        [a-zA-Z]" | grep -vE "Serial|Mirror|Online|Rotation|Main|Retina\:|Built\-In|Depth|Type\:" | sed -e 's/^\ \ \ \ \ \ \ \ /\ \ \ /g' -e 's/\:\ /\:\\t/g' -e s/'([^)]*)'/''/g )
	retval=$(system_profiler SPDisplaysDataType | grep -A 1000 " Displays\:" | grep -v "Display" | grep -B 1 -A 0 Resolution | grep -v "^--" | sed -e "s/^ *Resolution\://" -e "s/\ \ //g" | awk '{printf "  %s", $0; $0=""; getline; print "\t" $0}' | sed -e "s/^\ \ /\ \ $(printf "${Item}")/" -e "s/\:/\:$(printf "${Text}")/")
	printf "${Heading}Available Screens                                                                                                                      ${Color_Off}\n"
	printf "${Text}${retval}\n"
	printf "\n"
}

function get-hardware {
	local procval=""
	local memval=""
	procval=$(sysctl -n machdep.cpu.brand_string | sed 's/(R)//g; s/(TM)//g; s/\ CPU//g; s/Intel\ //g')
	local sockets=$(sysctl -n hw.packages)
	local cores=$(sysctl -n hw.physicalcpu)
	local threads=$(sysctl -n hw.logicalcpu)
	memval=$(sysctl -n hw.memsize | awk '{print $0/1073741824" GB"}';)
	printf "${Heading}System Information                                                                                                                  ${Color_Off}\n"
	printf "   ${Item}CPU:${Color_Off}\t\t${Text}${procval}"
	printf " (${sockets} sockets; ${cores} cores: ${threads} logical)${Color_Off}\n"
	#printf "   ${Item}Memory:${Color_Off}\t${Text}${memval}${Color_Off}\n\n"
	get-booted
}

function get-booted {
	printf "   ${Item}OS Ver:${Color_Off}\t${Text}$(sw_vers | grep -v "^Build" | awk -F':\t' '{print $2}' | paste -d " " - - -)${Color_Off}\n"
	printf "   ${Item}Kernel:${Color_Off}\t${Text}$(sysctl -n kern.version | cut -d \; -f 1 | sed 's/\ Kernel/,/g')${Color_Off}\n"
	printf "   ${Item}Booted:${Color_Off}\t${Text}$(date -r $(sysctl -n kern.boottime | awk '{print $4}' | sed 's/,//g') +'%a %m/%d/%Y at %I:%M%p')${Color_Off}\n"
	printf "   $(get_uptime)\n"
	printf "\n"
}

function get-panics {
	local retval=""
	retval=$(system_profiler SPLogsDataType | grep -A7 "Panic (system" | grep -vE "Source|Size|Modified|Contents|Panic|--" | tr -s "\n" | sed -e 's/^/\ \ /g' | tail -3 )
	if [[ ${retval} && ${retval-x} ]]; then
		printf "${Heading}Recent Kernel Panics                                                                                                          ${Color_Off}\n"
		printf "${Text}${retval}${Color_Off}\n"
		printf "\n"
	fi
}

function get-ps {
	local retval=""
	printf "${Heading}Process Utilization                                                                                                                         ${Color_Off}\n"
	echo "$(ps -amcxo "rss=Usage %mem=Mem command=App" | grep -v "com.apple" | head -5 | awk '{print $3, $1/1024 "mb", $2 "%"}' | sed 's/\(\.[0-9][0-9]\)[0-9]*/\1/g' | column -t && printf " ") $(ps -arcxo "command=App %cpu=CPU" | head -5)" | sed -e "s/^\ \ App/App/g" -e "s/\ \ 0mb\ \ /\ \ Usage/g" -e "s/Mem\%/\ Mem/g" | pr -2 -t | awk '{ printf "  %-16s %9s %5s  \|  %-16s %5s\n", $1, $2, $3, $4, $5 ; }' | sed -e "s/^\ \ App/\ \ $(printf "${SubHead}")App/g" -e "s/CPU/CPU$(printf "${Text}")/g"
}

function date-info {
	local retval=""
	retval=$(calendar -W 0 | sed -E "s/$(date -j '+%b %_d')../* /" | fold -s -w 73 | sed -e "s/^\([^*]\)/\ \ \ \ \ \ \ &/" -e "s/*/\ \ $(printf "${Item}")*$(printf "${Text}")/")
	printf "${Heading}On this day in history...                                                                                                                         ${Color_Off}${Text}\n"
	echo "${retval}"
	printf "\n"
}

function day-info {
	local retval=""
	local weatherdata=""
	local loc="http://www.wunderground.com/cgi-bin/findweather/getForecast?query=pws:MRWCC1"

	weatherdata=$(curl -s ${loc} | textutil -convert txt -stdin -stdout -format html | grep -E "Rise|Length of Day" -A4)

	if [[ ${weatherdata} && ${weatherdata-x} ]]; then
		local sunrise=$(echo "${weatherdata}" | grep "Rise" -A 3 | tail -1 | sed -e "s/\ PDT//" | tr '[:upper:]' '[:lower:]')
		local sunset=$(echo "${weatherdata}" | grep "Rise" -A 4 | tail -1 | sed "s/\ PDT//" | tr '[:upper:]' '[:lower:]')
		local daylength=$(echo $(echo "${weatherdata}" | grep "Length" -A 1 | tail -1)) ## | sed -e "s/\.\ \-//"))
		local moonphase=$(echo "${weatherdata}" | grep "the Moon" | sed "s/\%/\%\%/g")
		printf "${Heading}Sun and Moon Info                                                                                                                  ${Color_Off}\n"
		printf "  ${Item}SunRise:${Text} ${sunrise}\t  ${Item}SunSet:${Text} ${sunset}${Color_Off}\t"
		printf "  ${Item}Length:${Text} ${daylength}${Color_Off}\n"
		printf "  ${Item}Moon Phase:${Text} ${moonphase}${Color_Off}\n"
		printf "\n"
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

function OutBDay {
	local retval=""
	local HowOldAmI=""
	local BeforeBDay=0
	
	local bdate="${1}"
	local InclTotal=${2:-0}
	local Granul=${3:-m}

	local bmonth=${bdate:0:2}
	local bday=${bdate:3:2}
	local byear=${bdate:6:4}

	local cdate=$(date -j "+%m/%d/%Y-%H-%M")

	local cmonth=${cdate:0:2}
	local cday=${cdate:3:2}
	local cyear=${cdate:6:4}

	if [[ "${cmonth#0}" -lt "${bmonth#0}" ]] || [[ "${cmonth#0}" -eq "${bmonth#0}" && "${cday#0}" -lt "${bday#0}" ]]; then
		let HowOldAmI=cyear-byear-1
		BeforeBDay=0
	else
 		let HowOldAmI=cyear-byear
 		BeforeBDay=1
	fi

	local NextBDay="${bmonth}/${bday}/$(date -j -v +${BeforeBDay}y +%Y)-00-00"
	
	#printf "$(LongOutTime $(dateDiff $(date2secs ${cdate}) $(date2secs ${NextBDay})) m)" | awk '{ printf "%3s %-4s  %2s %-5s  %2s %-7s", $1, $2, $3, $4, $5, $6; }'
	printf "$(LongOutTime $(dateDiff $(date2secs ${cdate}) $(date2secs ${NextBDay})) m)" | awk '{ printf " %6s  %4s   %4s", $1, $3, $5; }'

	printf "   ${NextBDay:0:10}"
	if [ "${InclTotal}" -eq "0" ]; then printf "$((${HowOldAmI} + 1 ))" | awk '{ printf "  (%3s)", $1;}'; fi
}

function HowLongUntil {
	printf "${Heading}How Long Until...                                                                     ${Color_Off}\n"

	printf "${SubHead}"
	echo " ~Days~Hrs~Mins~Next Date~Years" | awk 'BEGIN{FS="~"}{ printf "%-21s %5s %5s %6s   %-10s  %5s", $1, $2, $3, $4, $5, $6; }'
	printf "\n"

	printf "  ${Item}My Birthday:${Text}\t\t"
	OutBDay "07/03/1921-00-00"
	printf "\n"
	printf "\n"
}

## Sets up for selecting which section at the command line
## The single number gives 1 section
## No number defaults to 99 ... which gives most sections
## Sections can be disabled from the full list by setting the 
##     -gt to more than 99
## A single section will include a blank line to start
What=${1:-99}

if [ ${What} -lt 90 ]; then echo " "; fi
if [ ${What} -eq 1 ] || [ ${What} -gt 90 ]; then get-hardware; fi
if [ ${What} -eq 2 ] || [ ${What} -gt 90 ]; then get-net; fi
if [ ${What} -eq 3 ] || [ ${What} -gt 90 ]; then get-disk; fi
if [ ${What} -eq 4 ] || [ ${What} -gt 90 ]; then get-screen; fi
if [ ${What} -eq 5 ] || [ ${What} -gt 90 ]; then get-panics; fi
if [ ${What} -eq 6 ] || [ ${What} -gt 90 ]; then get-users; fi
if [ ${What} -eq 7 ] || [ ${What} -gt 99 ]; then get-ps; fi
if [ ${What} -eq 8 ] || [ ${What} -gt 90 ]; then day-info; fi
if [ ${What} -eq 9 ] || [ ${What} -gt 90 ]; then date-info; fi
if [ ${What} -eq 10 ] || [ ${What} -gt 90 ]; then HowLongUntil; fi
