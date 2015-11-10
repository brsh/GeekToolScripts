#!/bin/bash
#Set the script's home directory
ScriptLoc="$(dirname $0)/lib"
#Now load the color and time_math libraries
source ${ScriptLoc}/lib_colors.sh
source ${ScriptLoc}/lib_time.sh

function get-net {
#CLI 1
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
local AllInfo=""
local IntStatus=""

#List out ALL of the network interfaces
for INTs in $(ifconfig -l); do
	#But we only care about the "active" interfaces with 'en' in them 
	if [ "${INTs:0:2}" = "en" ]; then
		#Reset used vars to empty (keeps output cleaner and more correct)
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
		WiFiDeets=""
		ifconfig=""
		ipconfig=""
		IntStatus=""
		
		#Run ifconfig against the interface, specifically, and pull out pieces of info
		ifconfig="$(ifconfig ${INTs})"
		IntStatus="$(echo "${ifconfig}" | awk '/status:[[:space:]]/ {print tolower($2)}')"
		if [ "${IntStatus}" = "active" ]; then
			#IP Address
			ipaddr=$(echo "${ifconfig}" | awk '/inet[[:space:]]/ {print $2 }')

			#Net Mask
			masktemp=$(echo "${ifconfig}" | awk '/inet[[:space:]]/ {print $4 }')
			#Check that the netmask is in the right format (cheat by using length)
			if [ ${#masktemp} -eq 10 ]; then
				#Convert the netmask to from Hex to dotted decimal
				netcalc="$((0x${masktemp:2:2} / 0x1)).$((0x${masktemp:4:2} / 0x1)).$((0x${masktemp:6:2} / 0x1)).$((0x${masktemp:8:2} / 0x1))"
			else
				netcalc="n/a"
			fi

			#MAC Address
			MACAddr=$(echo "${ifconfig}" | awk '/ether[[:space:]]/ {print $2 }')
		
			#Default gateway
			defgateway=$(netstat -nr | awk ' $1 == "default" { if ($6=="'${INTs}'") print $2 } ')
		
			#Shows (among other things) wired vs. wi-fi - we'll check for additional info if Wi-Fi
			ConType=$(networksetup -listallhardwareports | grep -B1 ${INTs} | awk -F:  ' /Port/ { sub("Hardware Port: ",""); print }')
			if [ "${ConType}" = "Wi-Fi" ]; then
				#SSID
				SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | awk ' / SSID:/ { print $2 }')
				if ! [[ "${SSID}" && "${SSID-x}" ]]; then
					SSID="n/a"
				else
					#Wi-Fi Standard (a, b, g, n, ac...) and color-coded signal strength
					#Pulls out the current interface first, in case there are multiple wireless adapters connected...
					#!! System_Profiler is ... slow (it's an inventory)
					#!! Disabling this 'else' call will speed things up a little
					#!! (and it won't break the display of info below)
					WiFiDeets="$(system_profiler SPAirPortDataType | grep -A25 "${INTs}" | grep -A10 "Current Network Information" | awk ' 
						function isnum(n) { return n ~ /^[+-]?[0-9]+\.?[0-9]*$/ }
						BEGIN{y=""; off="'${Color_Off}'"; warn="'${Yellow}'"; good="'${Green}'"; alert="'${Red}'"}
						/PHY Mode:/ { spec=$3 }
						/Signal \/ Noise:/ { 
							if (isnum($4) && isnum($7)) x=($4 - $7); else g="error";
							if (x > 40) sig="/ Signal: "good"Excellent"off;
							if (x < 41) sig="/ Signal: "good"Good"off;
							if (x < 26) sig="/ Signal: "warn"Low"off;
							if (x < 16) sig="/ Signal: "alert"Very Low"off;
							if (x < 11) sig="/ "alert"No Signal"off;
							if (g == "error") sig="";
						}; 
						END {print " / "spec" "sig}')"
				fi
			fi

			#DHCP information
			ipconfig=$(ipconfig getpacket ${INTs})		
			DHCPServer=$(echo "${ipconfig}" | awk ' BEGIN { FS="[=:]" }; /server_identifier/ {$1=""; gsub(" ","",$0); print $0 }')
			if ! [[ "${DHCPServer}" && "${DHCPServer-x}" ]]; then
				DHCPServer="Static IP or no DHCPServer"
	# 		else
	# 			#Have to review DHCP lease time
	# 			#ipconfig doesn't actually show when the lease was granted (so this calc is wrong)
	# 			#btw - /private/var/db/dhcpclient/leases/ holds 
	# 			#plus t1 = when it will try to renew with existing dhcpserver
	# 			#and  t2 = when it will try to renew with any dhcpserver
	# 			DHCPLeaseExpires=$(date -r $(echo $(date +%s) + $(( $(echo "${ipconfig}" | awk '/rebinding_t2_time_value[[:space:]]/ { $1=$2=""; print }') / 0x1 )) | bc) +'%a %m/%d/%Y %_I:%M%p')
	# 			DHCPLeaseExpires="(${Item}Lease Expires:${Text} ${DHCPLeaseExpires})${ColorOff}"
			fi
			#DNS Server(s)
			DNSServer=$(echo "${ipconfig}" | awk 'BEGIN { FS="[{}]"}; /domain_name_server[[:space:]]/ { print $2 }')

			#This interface's summary		
			if [[ "${ipaddr}" && "${ipaddr-x}" ]]; then
				AllInfo="${AllInfo} ${SubHead}${ConType} - interface ${INTs}${Color_Off}\n"
				AllInfo="${AllInfo}   ${Item}IP Address:${Color_Off}\t${Text}${ipaddr} / ${netcalc}${Color_Off}\n"
				AllInfo="${AllInfo}   ${Item}MAC Address:${Color_Off}\t${Text}${MACAddr}${Color_Off}\n"
				AllInfo="${AllInfo}   ${Item}DHCP Server:${Color_Off}\t${Text}${DHCPServer}${ColorOff} ${DHCPLeaseExpires}${ColorOff}\n"
				AllInfo="${AllInfo}   ${Item}Def Gateway:${Color_Off}\t${Text}${defgateway}${Color_Off}\n"
				AllInfo="${AllInfo}   ${Item}DNS Servers:${Color_Off}\t${Text}${DNSServer}${Color_Off}\n"
				if [ "${ConType}" = "Wi-Fi" ]; then
					AllInfo="${AllInfo}   ${Item}WiFi Info:${Color_Off}\t${Text}${SSID}${WiFiDeets}${Color_Off}\n"
				fi
				AllInfo="${AllInfo}\n"
			fi
		fi
	fi
done

#And the output (finally!)
if [[ "${AllInfo}" && "${AllInfo-x}" ]]; then
	out-Heading "Network Information"
	printf "${AllInfo}"
fi

}

function get-disk {
	#CLI 3
	#the usual disk space info
	out-Heading "Disk Information"
	printf "${SubHead}"
	echo "FileSystem Size Used Avail Used Mounted On" | awk '{printf "  %-24s %6s  %6s %6s   %s %s\n",  $1,$2,$4,$5,$6,$7 }'
	printf "${Text}"
	df -H -T nfs,hfs | awk 'NR>1 {printf "  %-24s %6s  %6s %6s   %s\n",  $1,$2,$4,$5,$9 }'
	printf "${Color_Off}"
	printf "\n"
}

function get-users {
	#CLI 6
	#prints who's logged on to the machine, their tty, and when
	out-Heading "Active User Summary"
	printf "${SubHead}"
	echo 'UserName~Terminal~Logged In~From?' | awk ' BEGIN {FS="~"}; { printf "  %-13s %-13s %-12s   %s\n", $1,$2,$3,$4 }' 
	printf "${Text}"
	who | awk '{ if ($6=="") $6="(local)"; printf "  %-13s %-13s %-3s %2s %-5s   %s\n", $1, $2, $3, $4, $5, $6 }'
	printf "${Color_Off}"
	printf "\n"
}

function get-screen {
	#CLI 4
	#lists the displays and their resolution
	local retval=""
	retval=$( system_profiler SPDisplaysDataType | awk ' /^        [a-zA-Z]/ { gsub("  ",""); printf "  '${Item}'%-17s'${Color_Off}'", $0 }; /  Resolution:/ { gsub("  ",""); if ($5=="Retina") x="Retina"; else x=""; printf "'${Text}'%6s%s%s %s'${Color_Off}'\n", $2,$3,$4,x}' )

	out-Heading "Available Screens"
	printf "${Text}${retval}\n"
	printf "\n"
}

function get-hardware {
	#CLI 1
	#pulls some info on the hardware and software
	local procval=""
	#Processor model and speed
	procval=$(sysctl -n machdep.cpu.brand_string | sed 's/(R)//g; s/(TM)//g; s/\ CPU//g; s/Intel\ //g')
	#How many sockets?
	local sockets=$(sysctl -n hw.packages)
	#How many cores
	local cores=$(sysctl -n hw.physicalcpu)
	#Hyperthreaded??
	local threads=$(sysctl -n hw.logicalcpu)
	#OS version
	local osver=$(sw_vers | awk ' /ProductName/ { $1=""; sub("^ ",""); printf $0; getline; printf " " $2 }')

	##Note: this next bit has some tricky date work (awk on mac doesn't have the built-in date functions)
	##I use SQ as a single quote since otherwise, it's even more tricky
	#Kernel version
	local kernver=$(sysctl -n kern.version | awk ' func formatdate(dWhen) { SQ="\047"; cmd="date -j -f " SQ "%a %b %d %H:%M:%S %Z %Y" SQ " " SQ "+%m/%d/%Y" SQ " " SQ dWhen SQ; cmd|getline retval; close(cmd); return retval } BEGIN { FS=": \|;" }; { sub("Version ",""); printf $1 " (" formatdate($2) ")" }')
	
	#Boot and reboot times
	local boottime=$(sysctl -n kern.boottime | awk 'BEGIN { FS="[ ,]"}; {print $4}')
	local unixtime=$(date +%s)
	local uptime=$((${unixtime} - ${boottime}))
	uptime="$(LongOutTime ${uptime} m)"
	local WhenBooted=$(date -r ${boottime} +'%a  %m/%d/%Y  at  %_I:%M%p')
	##last doesn't include the year, so neither do I.
	local lastfewboots=$(last | awk ' func formatdate(dM, dD, dH) {SQ="\047"; cmd="date -j -f " SQ "%b %d %H:%M" SQ " " SQ "+%m/%d       at  %_I:%M%p" SQ " " SQ dM " " dD " " dH SQ ; cmd|getline retval; close(cmd); return retval } BEGIN { x=0 } /reboot|shutdown/ { if (x>0) printf "\t\t\t%3s  %-21s  (%5s)\n", $3,formatdate($4,$5,$6),$1 ; if (x==4) exit; else x+=1 }')

	out-Heading "System Information"
	printf "   ${Item}CPU:${Color_Off}\t\t${Text}${procval}"
	printf " (${sockets} sockets; ${cores} cores: ${threads} logical)${Color_Off}\n"
	printf "   ${Item}OS Ver:${Color_Off}\t${Text}${osver} / ${kernver}${Color_Off}\n"
	printf "   ${Item}Up for:${Color_Off} \t${Text}${uptime}${Color_Off}\n"
	printf "   ${Item}Booted:${Color_Off}\t${Text}${WhenBooted}  (current boot)${Color_Off}\n"
	printf "${Color_Off}${Text}${lastfewboots}${Color_Off}\n"
	#Now, spin off to the AD function for password expiry info
	get-ADPassword
	printf "\n"
}

function get-ADPassword {
##Pull domain and password info
# Username and Domain 
## I keep these commented out of the final display - security!
local Me=""
local Domain=""

Me=$(whoami)
# SMB-style domain name
Domain=$(dscl localhost -read /Active\ Directory SubNodes 2> /dev/null | awk '{ print $2}')

if [[ "${Domain}" && "${Domain-x}" ]]; then
	local LDAPName=""
	local LDAProot=""
	local PwdLastSet=""
	local PwdMaxAge=""

	# DNS-style domain name
	LDAPName=$(dsconfigad -show | awk ' BEGIN {FS="="} /Forest/ { gsub(" ",""); print $2 }')
	local IsItAlive=$(ping -Q -c 2 -W 500 dolby.net | awk '/timeout/ { print "dead"; exit }')

	#My simple "cheat" of killing the ldap query after 5 seconds stopped working
	#So, instead, let's try a simple ping to see if the domain lives
	#Drawback - it has to ping and fail, which takes time;
	#           and it could fail cause... ping
	if [[ "${IsItAlive}" != "dead" ]]; then
		# LDAP-style domain name
		LDAProot=$(dscl localhost -read /Active\ Directory/${Domain}/${LDAPName} LDAPSearchBaseSuffix 2> /dev/null | awk '{ print tolower($2) }')

		# When was the password last set (in seconds)
		PwdLastSet=$(dscl localhost -read /Active\ Directory/${Domain}/${LDAPName}/Users/${Me} SMBPasswordLastSet 2> /dev/null| awk '{ printf "%d", ($2 / 10000000 - 11644473600) }') 

		# How old can the password be (in seconds)
		# and kill it in 5 seconds if it takes too long (this stopped working at some point... keeping it cause... reasons)
		# note: the killall method is potentially dangerous if you use ldapsearch for anything else
		(sleep 5 && killall ldapsearch 2> /dev/null) & PwdMaxAge=$(ldapsearch -LLL -Q -s base -H ldap://${LDAPName} -b "${LDAProot}" maxPwdAge 2> /dev/null | awk '/maxPwdAge/ {print (($2 * -1) / 10000000) }')

		if [[ "${PwdMaxAge}" && "${PwdMaxAge-x}" ]]; then
			# Figure out the important date information
			local Now=$(date -j +%s)
			local WhenLast=$(date -r ${PwdLastSet} +'%a, %b %d, %Y')
			local WhenNextSec=$(( PwdLastSet + PwdMaxAge ))
			local WhenNext=$(date -r ${WhenNextSec} +'%a, %b %d, %Y')
			local WhenNextDays=$(( (${WhenNextSec} - ${Now}) / 60 / 60 / 24 ))
		fi

		if [[ "${WhenLast}" && "${WhenLast-x}" ]]; then
			# Print what we've found
			printf "\n"
			#printf "   UserName:          ${Me}\n"
			#printf "   AD Domain:         ${Domain} (${LDAPName})\n"
			printf "   ${Item}AD Password last set:${Color_Off} ${Text}${WhenLast}${Color_Off}\n"
			printf "   ${Item}AD Password NEXT set:${Color_Off} ${Text}${WhenNext}  (in ${WhenNextDays} days)${Color_Off}\n"
		fi
	fi
fi
}

function get-panics {
	#CLI 5
	#If there've been any kernel panics reported in the system log, this will find 'em
	#Note: this stopped working in (or around) El Capitan (or earlier, who knows. Really only needed it in Mountain Lion)
	local retval=""

	retval=$(system_profiler SPLogsDataType | grep -A7 "Panic (system" | awk 'func formatdate(dWhen) { SQ="\047"; cmd="date -j -f " SQ "%a %b %d %H:%M:%S %Y" SQ " " SQ "+%a  %m/%d/%Y at %_I:%M%p" SQ " " SQ dWhen SQ; cmd|getline retval; close(cmd); return retval } BEGIN {i=0}; /^[a-zA-Z]/ { i+=1; printf "  %s", formatdate($0); if (i==3) exit; }')

	if [[ ${retval} && ${retval-x} ]]; then
		out-Heading "Kernel Panics"
		printf "${Text}${retval}${Color_Off}\n"
		printf "\n"
	fi
}

function date-info {
	#CLI 7
	local retval=""
	
	#This section expects the calendar files to exist
	#in the user's home directory under .calendar
	#see man calendar for more information...
	if [ -r "${HOME}/.calendar/calendar" ]; then
		#So, we run calendar, strip the date, wrap it at '73' characters, then use awk to wrap line 2 and put an * on line 1 (with color controls)
		retval=$(calendar -W 0 | sed -E "s/$(date -j '+%b %_d')../~ /" | fold -s -w 73 | awk ' $1!="~" { printf "    %s'${Color_Off}'\n", $0 } $1=="~" { $1=""; printf "'${Item}'*'${Text}'%s\n", $0 };')
		if ! [ -z "${retval}" ]; then
			#Only show this heading if there's some data to show with it...
			out-Heading "On this day in history..."
			echo "${retval}"
			printf "\n"
		fi
	fi
}

function OutBDay {
	#Syntax: OutBDay Target Title [InclTotals]
	#   where
	#		Target = the date to count to (in MM/DD/YY-Hr-Mn format)
	#		Title = text to print before the count
	#		InclTotals = 0 or nothing incl total year count; 1 don't incl total year count
	
	#Establish base vars
	local retval=""
	local HowOldAmI=""
	local BeforeBDay=0
	
	#break out the arguments
	local bdate="${1}"			#The first argument supplied (date)
	local InclTotal=${3:-0}		#The third argument - or 0 if nothing (include age)
	local sTitle="${2}"			#The second argument (the text to display)

	#break out the date components
	local bmonth=${bdate:0:2}	#The month
	local bday=${bdate:3:2}		#The day
	local byear=${bdate:6:4}	#The year

	#Get today in the "correct" format
	local cdate=$(date -j "+%m/%d/%Y-%H-%M")

	#Break out today components
	local cmonth=${cdate:0:2}
	local cday=${cdate:3:2}
	local cyear=${cdate:6:4}

	#Check if the "when" is before or after today
	if [[ "${cmonth#0}" -lt "${bmonth#0}" ]] || [[ "${cmonth#0}" -eq "${bmonth#0}" && "${cday#0}" -lt "${bday#0}" ]]; then
		let HowOldAmI=cyear-byear-1
		BeforeBDay=0
	else
 		let HowOldAmI=cyear-byear
 		BeforeBDay=1
	fi

	#Prepare the "next occurence" date - including the display thereof
	local NextBDay="${bmonth}/${bday}/$(date -j -v +${BeforeBDay}y +%Y)-00-00"
	local NextBDayExp=$(date -j -f "%m/%d/%Y" ${NextBDay:0:10} "+%A %m/%d/%Y" | awk '{ printf "%-9s %s", $1, $2 }')
	
	#output
	printf "  ${Item}$(echo "${sTitle}:" | awk ' {printf "%-21s", $0}')${Text}"
	printf "$(LongOutTime $(dateDiff $(date2secs ${cdate}) $(date2secs ${NextBDay})) d)" | awk '{ printf " %6s ", $1; }'

	printf "  ${NextBDayExp}"
	if [ "${InclTotal}" -eq "0" ]; then printf "$((${HowOldAmI} + 1 ))" | awk '{ printf "   (%3s)", $1;}'; fi

}

function HowLongUntil {
	#CLI 8
	#A simple function ... that calls other, less simple functions.
	#Print out how many days until something
	#Looks for a dates.txt file in a data subfolder under the script folder
	#	format:		item,date,includeAge
	#	example:	my birthday,01/02/03-00-00
	#				stepped on nail,04/05/06-09-15
	#		(where item and date are mandatory, and includeAge is optional)
	#Otherwise, you can specify items here in the script (see below)
	out-Heading "How Long Until..."

	#here's the heading
	printf "${SubHead}"
	echo " ~Days~Next  Occurrence~Years" | awk 'BEGIN{FS="~"}{ printf "%-23s %6s     %-10s     %5s", $1, $2, $3, $4; }'
	printf "\n"

	local Where="$(dirname $0)/data"
	local What=""

	#here's where we parse the dates file
	What="${Where}/dates.txt"
	if [ -r "${What}" ]; then
		while IFS=, read -r fTitle fDate fFlag; do
			OutBDay "${fDate}" "${fTitle}" "${fFlag}"
			printf "\n"
		done < "${What}"
	fi

	local tHold=""
	local tAlways=""
	local tDateDiff=""
	local tCloseTitle=""
	local tCloseDate=""
	local tCloseDiff=-31557700
	#here's where we parse the holidays file
	What="${Where}/holidays.txt"
	if [ -r "${What}" ]; then
		while IFS=, read -r fTitle fDate fDisplay fType; do
			if [[ "${fDisplay}" == "Always" ]]; then
				#Figure out the ones we always want to show
				if [[ "${fType}" == "FindNext" ]]; then
					tHold="$(FindNextOccurence ${fDate})-00-00"
				else
					tHold="${fDate}-00-00"
				fi
				#And add them to the Always var for display later
				tAlways+="$(OutBDay "${tHold}" "${fTitle}" 1)\n"
			else
				#Let's figure if this is the "next" holiday
				if [[ "${fType}" == "FindNext" ]]; then
					tHold="$(FindNextOccurence ${fDate})-00-00"
				else
					tHold="${fDate}-00-00"
				fi
				#Run through a calc to see if this is a future holiday
				tDateDiff="$((( $(date -j +%s) - $(date -jf "%m/%d/%Y-%H-%M" ${tHold:0:6}$(date -j +%Y)-00-00 +%s))))"
				if (( ${tDateDiff} < 0 )); then
					#Now check if we have a holiday saved; and save it if it's closer to now
					if (( ${tDateDiff} > ${tCloseDiff} )); then
						tCloseTitle="${fTitle}"
						tCloseDate="${tHold}"
						tCloseDiff="${tDateDiff}"
					fi
				fi
			fi
		done < "${What}"
		#Print the always items
		printf "${tAlways}"
		#Print the close date, only if we have one
		if [[ "${tCloseTitle}" != "" ]]; then
			OutBDay "${tCloseDate}" "${tCloseTitle}" 1
		fi
	fi

	#and here're samples of manual items
	#Thanksgiving is special (4 thurs in Nov)
	#	OutBDay "$(FindNextOccurence 11 TH 4)-00-00" "Thanksgiving" 1
	#	printf "\n"
	#	OutBDay "12/25/2014-00-00" "Christmas" 1
	#	printf "\n"
	#	OutBDay "01/01/2015-00-00" "New Years" 1
	#	printf "\n"
}

function FindNextOccurence {
	#Syntax: FindNextOccurence Month Day Which
	#	where Month is 2 digits for month
	#         Day is 2 letters (CAP'd) of the day (MO, TU, WE, etc)
	#		  Which is which one (1 = first, 2 = second, LA = last, etc)
	#Finds the next occurence of a holiday that occurs on different dates each year
	#Thanksgiving is 4th Thurs in Nov (so "FindNextOccurence 11 TH 4")
	#President's Day is 3rd Mon in Feb (so "FindNextOccurence 2 MO 3")
	local tYear
	local tDay
	local sMonth
	local sDay
	local iNumber
	sMonth="${1}"
	sDay="${2}"
	iNumber="${3}"
	#What's the current year
	tYear=$(date -j +%Y)
	tDay=$(specday "${tYear}" "${sMonth}" "${sDay}" "${iNumber}")
	#Now check if we've passed that month and day this year
	#Note: I force base 10 on all the numbers because bash can get confused with leading 0's
	if (( 10#$(date -j +%m) == 10#${sMonth} && 10#$(date -j +%d) > 10#${tDay} )) || (( 10#$(date -j +%m) > 10#${sMonth} )) ; then
			#Recalc the date for next year 
			tYear=$(date -j -v+1y +%Y)
			tDay=$(specday "${tYear}" "${sMonth}" "${sDay}" "${iNumber}")
	fi
	#and return the date we found
	printf "${sMonth}/${tDay}/${tYear}"	
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
if [ ${What} -eq 5 ] || [ ${What} -gt 190 ]; then get-panics; fi
if [ ${What} -eq 6 ] || [ ${What} -gt 90 ]; then get-users; fi
if [ ${What} -eq 7 ] || [ ${What} -gt 90 ]; then date-info; fi
if [ ${What} -eq 8 ] || [ ${What} -gt 90 ]; then HowLongUntil; fi
if [ ${What} -eq 75 ]; then Working; fi 
