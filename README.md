GeekToolScripts
===============

A collection of scripts for GeekTool on the mac.

* <b>gt-calendar.sh</b><br>
Displays a 3 month calendar, current month in the center, with the current day highlighted. 
The past and previous months are a different color from current, with the expired days of 
this month a different color too. Very colorful. 

* <b>gt-info.sh</b><br>
Huge info script. By default shows all info (command line switch listed in parens): <br>
  CPU, OS and Kernel version, last boot time and uptime (./gt-info.sh 1)<br>
  Network Info for all active NICs (./gt-info.sh 2): <br>
    IP, Mac, DHCP server, lease expiration, gateway, dns, and wifi ssid and tech
  Disk Info - size, space avail and used, %, and mount point (./gt-info.sh 3)<br>
  Monitors and resolution (./gt-info.sh 4)<br>
  Recent kernel panics (./gt-info.sh 5)<br>
  Current users, which TTY, and when logged in (./gt-info.sh 6)<br>
  This day in history (expects ~/.calendar files) (./gt-info.sh 7)<br>
  How Long Until... various days (expects ./data/dates.txt) (./gt-info.sh 8)<br>
  
* <b>gt-weather.sh</b><br>
Obligatory weather information. Includes temp, forecast, the usual....

* <b>gt-quote.sh</b><br>
Obligatory quote script

* <b>gt-time.sh</b><br>
Simple display of time in a couple zones...

* <b>gt-meters.sh</b><br>
Uses progbar.sh to output load, cpu, memory, and disk utilization. Also battery.
ALSO, out prints out top processes by cpu and by memory util, in 2 cols.
Includes command line switches to select what displays and in what order.... 
Bars are colored based on various percentages...
```
		-l	load bar <br>
		-c	cpu util bar <br>
		-m	mem util bar <br>
		-d	disk util bar <br>
		-b	batt util bar <br>
		-p	processes <br>
```

Lib Scripts
These are found in the ./lib/ folder - they are required for some (or all) of the above scripts
* <b>progbar.sh</b><br>
Not-so-simple multi-color progress bar (now, not so simple...)
```
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
```
* <b>lib_colors.sh</b><br>
  GT-safe colors referenced in the scripts

* <b>lib_time.sh</b><br>
  Some small time conversion scripts (mostly to get the "x days y hours" format)
