GeekToolScripts
===============

A collection of scripts for GeekTool on the mac.

* gt-calendar.sh
Displays a 3 month calendar, current month in the center, with the current day highlighted. 
The past and previous months are a different color from current, with the expired days of 
this month a different color too. Very colorful. 

* gt-info.sh
Huge info script. Shows:
  CPU, OS and Kernel version, last boot time and uptime
  Network Info for all active NICs: 
    IP, Mac, DHCP server, lease expiration, gateway, dns, and wifi ssid and tech
  Disk Info - size, space avail and used, %, and mount point
  Monitors and resolution
  Recent kernel panics
  Current users, which TTY, and when logged in
  Sun rise and set, moon phase
  This day in history (expects ~/.calendar files)
  How Long Until... various days
  
* gt-weather.sh
Obligatory weather information. Includes temp, forecast, the usual....

* gt-quote.sh
Obligatory quote script

* gt-time.sh
Simple display of time in a couple zones...

* progbar.sh
Simple multi-color progress bar (now, not so simple...)
	progbar.sh [options] amount [total] [width] 
        -r	Reverse the bar's order
        -l	Label
        -p	Label position (L, R, or LR)
        -b	Background color
        -n	Normal indicator color
        -u	High indicator color
        -t	High threshold (percent)
        -o	Low indicator color
        -w	Low threshold (percent)
		Color Options: Black, Red, Yellow, Blue, Green, Purple, Cyan, White, Off

* gt-meters.sh
Uses progbar.sh to output load, cpu, memory, and disk utilization. Also battery.
ALSO, out prints out top processes by cpu and by memory util, in 2 cols.
Includes command line switches to select what displays and in what order....
		-l	load bar
		-c	cpu util bar
		-m	mem util bar
		-d	disk util bar
		-b	batt util bar
		-p	processes
	Bars are colored based on various %ages
