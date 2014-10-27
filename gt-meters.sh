#!/bin/bash
Width=50
ScriptLoc="~/scripts/geektool"
. ~/scripts/geektool/colors.sh
BG="Off"

function out-batt {
	local ioreg=$(ioreg -n AppleSmartBattery | grep "ExternalConnected\|CurrentCapacity\|MaxCapacity\|IsCharging" | awk '{print $5}')
	local ac_adapt=$(echo ${ioreg} | awk '{print $1}')
	local ac_charging=$(echo ${ioreg} | awk '{print $4}')
	local max_power=$(echo ${ioreg} | awk '{print $2}')
	local cur_power=$(echo ${ioreg} | awk '{print $3}')
	local bat_percent=$(echo "scale=2;${cur_power} / ${max_power}" | bc)
	bat_percent=$(echo "${bat_percent} * 100" | bc | sed 's/\.00//')

	local Label="B"

	if [ ${ac_charging} == "Yes" ]; then
		Label="+"
	fi
	if [ ${ac_adapt} == "No" ]; then
		Label="-"
	fi

	~/scripts/geektool/progbar.sh -l ${Label} -n Yellow -b ${BG} -u White -t 60 -o Red -w 20 ${bat_percent} 100 ${Width}
	printf "\n"
}

function out-processes {
	#Couldn't make "else" work in awk... nor the bash varbs... didn't try very hard... 
	printf "$(ps -arcxo "command=App %cpu=Load" | head -7 | sed s/\ \ *\ /~/ )\n$(ps -amcxo "command=App %mem=Mem" | grep -v "com.apple" | head -7 | sed s/\ \ *\ /~/  )" | pr -2 -t | sed -e "s/\ \ *\ /~/" | tr "\t" "~" | tr -s "~" |
			awk '
				BEGIN{FS="~"; black="\033[30m"; red="\033[31m"; white="\033[37m"; green="\033[32m"; yellow="\033[33m"; onblack="\033[40m"; onred="\033[41m"; onyellow="\033[43m"; off="\033[0m"; }
				$1 == "App" { printf yellow onblack"%-20s %-5s%%    %-20s %-4s%%"off"\n", $1, $2, $3, $4; x1=$1; x2=$2; x3=$3; x4=$4; }
				$1 != "App" { 
					if ($2 > -1) cColor=off;
					if ($2 > 40) cColor=black onyellow;
					if ($2 > 80) cColor=white onred;
					if ($4 > -1) mColor=off;
					if ($4 > 20) mColor=black onyellow;
					if ($4 > 40) mColor=white onred;
					printf cColor"%-20s %6s"off"    "mColor"%-21s %4s"off"\n", $1, $2, $3, $4; 
				}
				END{ printf yellow onblack"%-20s %-5s%%    %-20s %-4s%%"off"\n", x1, x2, x3, x4; }
				'
}

function out-memory {
	#Top sometimes shows M sometimes G... 
	#This should straighten out the sizing errors
	local memuse=$(top -l 1 | awk '/PhysMem/ {printf $2 }' | tr '[:lower:]' '[:upper:]')
	local power=$(echo "${memuse}" | sed s/[0-9\ ]//g)
	local memtotal=16
	case ${power} in 
		M ) memtotal=16000
		;;
		K ) memtotal=16000000
		;;
	esac
	~/scripts/geektool/progbar.sh -l M -n Yellow -b ${BG} -u Red -t 95 -o White -w 85 $(echo "${memuse}" | sed s/[mMgGkK]//) ${memtotal} ${Width}
	printf "\n"
}

function out-load {
	#CPU total (via all processes' CPU via ps)
	~/scripts/geektool/progbar.sh -l L -n Yellow -b ${BG} -u Red -t 85 -o White -w 50 $(printf %.0f $(ps axo %cpu | awk {'sum+=$1;print sum'} | tail -n 1)) 400 ${Width}
	printf "\n"
}

function out-cpu {
	#CPU overall utilization (via top)
	~/scripts/geektool/progbar.sh -l C -n Yellow -b ${BG} -u Red -t 85 -o White -w 50 $(echo $(( 100 - $(top -l 2 | awk '/CPU usage/{i++} i==2{print; exit;}' | awk '{print $7}' | head -c2) ))) 100 ${Width}
	printf "\n"
}

function out-disk {
	#Disk util (via df)
	~/scripts/geektool/progbar.sh -l D -n Yellow -b ${BG} -u Red -t 95 -o White -w 70 $(df -h "/" | awk 'NR==2{printf "%s", $5}' | sed s/\%//) 100 ${Width}
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


#awk 'BEGIN{for(c=0;c<'$(( ${Width} + 5 ))';c++) printf "\033[40m "}'