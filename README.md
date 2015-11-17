GeekToolScripts
===============

A collection of scripts for GeekTool on the mac. Note: I use geektool to set the "default" color and only enhance some colors via ANSI codes. The calendar is a prime example of this

* <b>gt-calendar.sh</b><br>
Displays a 3 month calendar, current month in the center, with the current day highlighted. 
The past and previous months are a different color from current, with the expired days of 
this month a different color too. Very colorful. 

* <b>gt-info.sh</b><br>
Huge info script. By default shows all info (command line switch listed in parens):
 - CPU, OS and Kernel version, last boot time and uptime, and AD password expiry (./gt-info.sh 1)<br>
 - Network Info for all active NICs (./gt-info.sh 2): <br>
  .   IP, Mac, DHCP server, lease expiration, gateway, dns, and wifi ssid, signal strength and tech <br>
 -  Disk Info - size, space avail and used, %, and mount point (./gt-info.sh 3)<br>
 -  Monitors and resolution (./gt-info.sh 4)<br>
 -  DISABLED: Recent kernel panics (./gt-info.sh 5)<br>
 -  Current users, which TTY, and when logged in (./gt-info.sh 6)<br>
 -  This day in history (expects calendar and ~/.calendar files) (./gt-info.sh 7)<br>
 -  How Long Until... various days (expects ./data/dates.txt and/or ./data/holidays.txt) (./gt-info.sh 8)<br>
  
* <b>gt-weather.sh</b><br>
Obligatory weather information. Includes temp, forecast, the usual.... Doesn't work anymore. Not worth fixing.

* <b>gt-quote.sh</b><br>
Obligatory quote script. Also doesn't work anymore and not worth fixing.

* <b>gt-time.sh</b><br>
Simple display of time in a couple zones...

* <b>gt-meters.sh</b><br>
Uses progbar.sh to output load, cpu, memory, and disk utilization. Also battery.
ALSO, out prints out top processes by cpu and by memory util, in 2 cols.
Includes command line switches to select what displays and in what order.... 
Bars are colored based on various percentages...
```
		-w	width in characters
		-g	background (aka "no signal") color
		-l	load bar
		-c	cpu util bar
		-m	mem util bar
		-d	disk util bar
		-b	batt util bar
		-p	processes
```

* <b>gt-monitordetect.sh</b><br>
Detect if my 2 side monitors are plugged in and run appropriate AppleScript scripts
to enable or disable the geeklets on those monitors (and, maybe, geeklets on the 
laptop's sceen that become redundant.
Requires/Expects: gt-monitorleft-on.scpt, gt-monitorleft-off.scpt, gt-monitorright-on.scpt, gt-monitorright-off.scpt,

* <b>gt-musictrackinfo.sh</b><br>
The obligatory script to pull music track info (song title, artist/group, album, and if paused).
For me, it's Vox (as a Windows guy, I have wma files). 
Expects: gt-musictrackinfo.scpt


Lib Scripts
These are found in the ./lib/ folder - they are required for some (or all) of the above scripts
* <b>progbar.sh</b><br>
Not-so-simple multi-color progress bar
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
