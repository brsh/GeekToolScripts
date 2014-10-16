#!/bin/bash

# Note: see /usr/share/zoneinfo/ for TZ info

function india-time {
	# Roughly India...
	TZ=Asia/Calcutta date -j "+%a %_I:%M%p (India)" | sed -e s/AM/am/ -e s/PM/pm/
}

function dayton-time {
	#Eastern Time Zone
	TZ=America/New_York date -j "+%a %_I:%M%p (Dayton)" | sed -e s/AM/am/ -e s/PM/pm/
}

function loc-time {
	date -j "+%a %_I:%M%p" |  sed -e s/AM/am/ -e s/PM/pm/
}

case "${1}" in
	I* | i* )
		india-time
	;;
	D* | d* )
		dayton-time
	;;
	* )
		loc-time
	;;
esac

