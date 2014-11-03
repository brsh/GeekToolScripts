#!/bin/bash
ScriptLoc="$(dirname $0)/lib"
source ${ScriptLoc}/lib_colors.sh
source ${ScriptLoc}/lib_time.sh

function out-Heading {	
	#Makes a pretty (and consistent) heading 
	printf "${Heading}"
	printf "${*}"
	printf "%0.s " {1..100}
	printf "${Color_Off}\n"
}

function get-net {
#very convoluted (but fact-filled) network info
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

out-Heading "Network Information"
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
		defgateway=$(netstat -nr | awk ' $1 == "default" { if ($6=="'${INTs}'") print $2 } ')

		ConType=$(networksetup -listallhardwareports | grep -B1 ${INTs} | awk -F:  ' /Port/ { sub("Hardware Port: ",""); print }')
		if [ "${ConType}" = "Wi-Fi" ]; then
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
	#the usual disk space info
	out-Heading "Disk Information"
	printf "${SubHead}"
	echo "FileSystem Size Used Avail Used Mounted On" | awk '{printf "  %-24s %6s  %6s %6s   %s %s\n",  $1,$2,$4,$5,$6,$7 }'
	printf "${Text}"
	df -H -T nfs,hfs | awk '{printf "  %-24s %6s  %6s %6s   %s\n",  $1,$2,$4,$5,$9 }' | tail +2
	printf "${Color_Off}"
	printf "\n"
}

function get-users {
	#prints who's logged on to the machine, their tty, and when
	out-Heading "Active User Summary"
	printf "${SubHead}"
	echo 'UserName Terminal Time Logged In' | awk '{printf "  %-16s   %-15s %s %s %s\n", $1, $2, $3, $4, $5;}'
	printf "${Text}"
	who | awk '{ printf "    %-16s %-15s %s %s %s\n", $1, $2, $3, $4, $5 ; }'
	printf "${Color_Off}"
	printf "\n"
}

function get_uptime() {
	#prints how long since the last boot
	local retval=""
    local uptime

	local boottime=$(sysctl -n kern.boottime | awk '{print $4}' | sed 's/,//g')
	local unixtime=$(date +%s)
	uptime=$((${unixtime} - ${boottime}))

	retval="$(LongOutTime ${uptime} m)"
	printf "${Item}Up for:${Color_Off} \t${Text}${retval}${Color_Off}"
}

function get-screen {
	#lists the displays and their resolution
	local retval=""
	local sDisplays="$(system_profiler SPDisplaysDataType | grep -A 1000 " Displays\:")"
	retval=$( echo "${sDisplays}" | awk ' /^        [a-zA-Z]/ { gsub("  ",""); printf "  "red"%-17s"off, $0 }; /  Resolution:/ { gsub("  ",""); if ($5=="Retina") x="Retina"; else x=""; printf "%6s%s%s %s\n", $2,$3,$4,x}' | sed -e "s/^\ \ /\ \ $(printf "${Item}")/" -e "s/\:\ \ /\:\ \ $(printf "${Text}")/")

	out-Heading "Available Screens"
	printf "${Text}${retval}\n"
	printf "\n"
}

function get-hardware {
	#pulls some info on the hardware and software
	local procval=""
	procval=$(sysctl -n machdep.cpu.brand_string | sed 's/(R)//g; s/(TM)//g; s/\ CPU//g; s/Intel\ //g')
	local sockets=$(sysctl -n hw.packages)
	local cores=$(sysctl -n hw.physicalcpu)
	local threads=$(sysctl -n hw.logicalcpu)
	out-Heading "System Information"
	printf "   ${Item}CPU:${Color_Off}\t\t${Text}${procval}"
	printf " (${sockets} sockets; ${cores} cores: ${threads} logical)${Color_Off}\n"
	printf "   ${Item}OS Ver:${Color_Off}\t${Text}$(sw_vers | grep -v "^Build" | awk -F':\t' '{print $2}' | paste -d " " - - -)${Color_Off}\n"
	printf "   ${Item}Kernel:${Color_Off}\t${Text}$(sysctl -n kern.version | cut -d \; -f 1 | sed 's/\ Kernel/,/g')${Color_Off}\n"
	printf "   ${Item}Booted:${Color_Off}\t${Text}$(date -r $(sysctl -n kern.boottime | awk '{print $4}' | sed 's/,//g') +'%a %m/%d/%Y at %I:%M%p')${Color_Off}\n"
	printf "   $(get_uptime)\n"
	printf "\n"
}

function get-panics {
	#If there've been any kernel panics reported in the system log, this will find 'em
	local retval=""
	retval=$(system_profiler SPLogsDataType | grep -A7 "Panic (system" | grep -vE "Source|Size|Modified|Contents|Panic|--" | tr -s "\n" | sed -e 's/^/\ \ /g' | tail -3 )
	if [[ ${retval} && ${retval-x} ]]; then
		out-Heading "Recent Kernel Panics"
		printf "${Text}${retval}${Color_Off}\n"
		printf "\n"
	fi
}

function date-info {
	local retval=""
	
	#This section expects the calendar files to exist
	#in the user's home directory under .calendar
	#see man calendar for more information...
	if [ -r ~/.calendar/calendar ]; then
		retval=$(calendar -W 0 | sed -E "s/$(date -j '+%b %_d')../* /" | fold -s -w 73 | sed -e "s/^\([^*]\)/\ \ \ \ \ \ \ &/" -e "s/*/\ \ $(printf "${Item}")*$(printf "${Text}")/")
		out-Heading "On this day in history..."
		echo "${retval}"
		printf "\n"
	fi
}

function OutBDay {
	#Syntax: OutBDay Target Title [InclTotals]
	#   where
	#		Target = the date to count to (in MM/DD/YY-Hr-Mn format)
	#		Title = text to print before the count
	#		InclTotals = 0 or nothing incl total year count; 1 don't incl total year count
		
	local retval=""
	local HowOldAmI=""
	local BeforeBDay=0
	
	local bdate="${1}"
	local InclTotal=${3:-0}
	local sTitle="${2}"

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

	#output
	local NextBDay="${bmonth}/${bday}/$(date -j -v +${BeforeBDay}y +%Y)-00-00"
	
	printf "  ${Item}$(echo "${sTitle}:" | awk ' {printf "%-18s", $0}')${Text}"
	printf "$(LongOutTime $(dateDiff $(date2secs ${cdate}) $(date2secs ${NextBDay})) m)" | awk '{ printf " %6s  %4s   %4s", $1, $3, $5; }'

	printf "   ${NextBDay:0:10}"
	if [ "${InclTotal}" -eq "0" ]; then printf "$((${HowOldAmI} + 1 ))" | awk '{ printf "  (%3s)", $1;}'; fi
}

function HowLongUntil {
	#A simple function ... that calls other, less simple functions.
	#Print out how many days until something
	#Looks for a dates.txt file in a data subfolder under the script folder
	#	format:		item,date,includeAge
	#	example:	my birthday,01/02/03-00-00
	#				stepped on nail,04/05/06-09-15
	#		(where item and date are mandatory, and includeAge is optional)
	#Otherwise, you can specify items in the script
	out-Heading "How Long Until..."

	#here's the heading
	printf "${SubHead}"
	echo " ~Days~Hrs~Mins~Next Date~Years" | awk 'BEGIN{FS="~"}{ printf "%-21s %5s %5s %6s   %-10s  %5s", $1, $2, $3, $4, $5, $6; }'
	printf "\n"

	#here's where we parse the file
	local Where="$(dirname $0)/data"
	if [ -r "${Where}/dates.txt" ]; then
		while IFS=, read -r f1 f2 f3; do
			OutBDay "${f2}" "${f1}" "${f3}"
			printf "\n"
		done < "${Where}/dates.txt"

	fi

	#and here're the manual items
	OutBDay "11/27/2014-00-00" "Thanksgiving" 1
	printf "\n"
	OutBDay "12/25/2014-00-00" "Christmas" 1
	printf "\n"
	OutBDay "01/01/2015-00-00" "New Years" 1
	printf "\n"
}

function Working {
	## just a temporary working function where I can test stuff
	echo "noop"
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
if [ ${What} -eq 7 ] || [ ${What} -gt 90 ]; then date-info; fi
if [ ${What} -eq 8 ] || [ ${What} -gt 90 ]; then HowLongUntil; fi
if [ ${What} -eq 75 ]; then Working; fi 
