#!/bin/bash
Width=50
ScriptLoc="$(dirname $0)/lib"
. ${ScriptLoc}/lib_colors.sh
BG="Off"

function out-batt {
	local bat_percent="" 

	local Label="B"
	
	eval $(ioreg -n AppleSmartBattery | awk ' BEGIN { FS=" = "} /ExternalConnected/ { if (tolower($2)=="no") print "Label=-" } /CurrentCapacity/ { cur=$2 } /MaxCapacity/ { max=$2 } /IsCharging/ { if (tolower($2)=="yes") print "Label=+" } END { print "bat_percent=" int(cur / max * 100) }')

	${ScriptLoc}/progbar.sh -l ${Label} -n Yellow -b ${BG} -u White -t 60 -o Red -w 20 ${bat_percent} 100 ${Width}
	printf "\n"
}

function out-processes {
	#Couldn't make "else" work in awk... didn't try very hard... 
	printf "$(ps -arcxo "command=App %cpu=Load" | head -7)\n$(ps -amcxo "command=App %mem=Mem" | grep -v "com.apple" | head -7 )" | pr -2 -t | sed "s/\ \ *\ /~/g" | tr "\t" "~" | tr -s "~" |
			awk '
				BEGIN{FS="~"; off="'${Color_Off}'"; header="'${Yellow}${On_Black}'"; warn="'${Black}${On_Yellow}'"; alert="'${White}${On_Red}'"}
				$1 == "App" { printf header"%-20s %6s    %-20s %6s"off"\n", "App", "Load %", "App", "Mem %" }
				$1 != "App" { 
					if ($2 > -1) cColor=off;
					if ($2 > 40) cColor=warn;
					if ($2 > 80) cColor=alert;
					if ($4 > -1) mColor=off;
					if ($4 > 20) mColor=warn;
					if ($4 > 40) mColor=alert;
					if (length($1)>20) $1=substr($1, 0, 16) "...";
					if (length($3)>20) $1=substr($3, 0, 16) "...";
					printf cColor"%-20s %6s"off"    "mColor"%-20s %6s"off"\n", $1, $2, $3, $4; 
				}
				END{ printf header"%-20s %6s    %-20s %6s"off"\n", "App", "Load %", "App", "Mem %" }
				'
}

function out-memory {
	#Top sometimes shows M sometimes G... 
	#This should straighten out the sizing errors
	local memuse=$(top -l 1 | awk '/PhysMem/ {printf $2 }')
	
	local power=$(echo "${memuse}" | sed s/[0-9\ ]//g)
	local memtotal=16
	case ${power} in 
		M|m ) memtotal=16000
		;;
		K|k ) memtotal=16000000
		;;
	esac
	${ScriptLoc}/progbar.sh -l M -n Yellow -b ${BG} -u Red -t 95 -o White -w 85 $(echo "${memuse}" | sed s/[mMgGkK]//) ${memtotal} ${Width}
	printf "\n"
}

function out-load {
	#CPU total (via all processes' CPU via ps)
	${ScriptLoc}/progbar.sh -l L -n Yellow -b ${BG} -u Red -t 85 -o White -w 50 $(ps axo %cpu | awk '{sum+=$1 } END {printf "%d", sum}') 400 ${Width}
	printf "\n"
}

function out-cpu {
	#CPU overall utilization (via top)
	${ScriptLoc}/progbar.sh -l C -n Yellow -b ${BG} -u Red -t 85 -o White -w 50 $(top -l 2 | awk 'BEGIN { FS="sys, \| idle" } /CPU usage/{i++} i==2{printf "%d", 100-$2; exit;}') 100 ${Width}
	printf "\n"
}

function out-disk {
	#Disk util (via df)
	${ScriptLoc}/progbar.sh -l D -n Yellow -b ${BG} -u Red -t 95 -o White -w 70 $(df -h "/" | awk 'NR==2{printf "%d", $5}') 100 ${Width}
	printf "\n"
}

OPTIND=1 # Reset is necessary if getopts was used previously in the script.  It is a good idea to make this local in a function.
while getopts ":lcmdbp" opt; do
	case "$opt" in
		l ) out-load
		;;
		c ) out-cpu
		;;
		m ) out-memory
		;;
		d ) out-disk
		;;
		b ) out-batt
		;;
		p ) out-processes
		;;
		\? )
			out-processes
			out-load
			out-cpu
			out-memory
			out-disk
			out-batt
		;;
	esac
done
