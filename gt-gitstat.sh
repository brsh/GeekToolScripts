#!/bin/bash
ScriptLoc="$(dirname $0)/lib"
source ${ScriptLoc}/lib_colors.sh

for i in $( find /Users/bshea/scripts/github -type d -d 1 ); do
	cd ${i}
	git status &> /dev/null
	if ! [ $? -gt 0 ]; then
	
		#Print the folder ... minus the lead up
		printf "${Yellow}$(echo "${i##*/}")${Color_Off}\n"

		#Print the status of the repo		
		git status | awk ' $1 != "#" { gsub(/ \(.*\)/,"",$0); print "  "toupper(substr($0,1,1)) substr($0,2,1000) }'

		#Output the git log for the past 2 commits and when they happened
		git --no-pager log --abbrev-commit --date=relative -2 | 
			awk '
				$1 == "Date:" { gsub("  ",""); 
					gsub(/^[ \t]+|[ \t]+$/,""); 
					sub("Date: ","",$0); 
					x=$0; 
					getline; 
					if ($0="\n") getline; 
					gsub("  ",""); 
					gsub(/^[ \t]+|[ \t]+$/,""); 
					printf "    %-15s  %s\n", x, $0 }
				'
	fi
done

