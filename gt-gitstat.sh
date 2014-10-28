#!/bin/bash

for i in $( find /Users/bshea/scripts/github -type d -d 1 ); do
	cd ${i}
	git status &> /dev/null
	if ! [ $? -gt 0 ]; then
	
		#Print the folder ... minus the lead up
		temphold=$(echo "${i}" | sed -e "s~\/Users\/bshea\/scripts\/github\/~~")
		printf "${Yellow}${temphold}${Color_off}\n"

		#Print the status of the repo		
		#git status | grep -vE "^#$|#   \(" | tail +2 | sed -e 's/#   (use.*//' -e 's/^#$//' -e 's/^/\ \ /' | tr -s "\n"
		#git status | grep -vE "^#" | sed -e 's/#   (use.*//' -e 's/^#$//' -e 's/^/\ \ /' -e 's/(*)//' | tr -s "\n"
		git status | awk ' $1 != "#" { gsub(/ \(.*\)/,"",$0); print "  "toupper(substr($0,1,1)) substr($0,2,100) }'

		#Output the git log for the past 2 commits and when they happened
		git --no-pager log --abbrev-commit --date=relative -2 | tr -s "\n" | awk '$1 == "Date:" { gsub("  ",""); gsub(/^[ \t]+|[ \t]+$/,""); sub("Date: ","",$0); x=$0; getline; gsub("  ",""); gsub(/^[ \t]+|[ \t]+$/,""); printf "    %-14s  %s\n", x, $0 }'

		#clean up
		unset temphold
	fi
done

