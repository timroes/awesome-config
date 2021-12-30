#! /bin/bash	

# For this script to work you need write rights to the /sys/class/backlight/*/brightness devices.	
# This could e.g. be accomplished by an udev rule with the following content:	

# /etc/udev/rules.d/backlight.rules
# SUBSYSTEM=="backlight", ACTION=="add", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"	
# SUBSYSTEM=="backlight", ACTION=="add", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"	

# You then need to be in the video group.

device=$1
# OLED screens deliver a wrong max_brightness value, so we need to manual set this to the actual max value.
max="$(cat $device/max_brightness)"

if [ -z "$device" ]; then
	exit 1
fi

if [ "$3" == "small" ]; then
	step=$(($max/150))
else
	step=$(($max/15))
fi

current=`cat $device/brightness`
if [ $current -gt $max ]; then
	current=$max
fi

case "$2" in
	"up")
		new=$(($current+$step))
		if [ $new -gt $max ]; then
			new=$max
		fi
		echo $new > $device/brightness
		echo $(($new * 100 / $max))
		;;
	"down")
		new=$(($current-$step))
		if [ $new -lt 1 ]; then
			new=1
		fi
		echo $new > $device/brightness
		echo $(($new * 100 / $max))
		;;
esac