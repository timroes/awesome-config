#! /bin/bash

# For this script to work you need write rights to the /sys/class/backlight/*/brightness devices.
# This could e.g. be accomplished by an udev rule with the following content:

# SUBSYSTEM=="backlight", ACTION=="add", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
# SUBSYSTEM=="backlight", ACTION=="add", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"

# You then need to be in the video group.

DEVICES=(
	'intel_backlight'
	'thinkpad_screen'
)

for x in "${DEVICES[@]}"
do
	if [ -e "/sys/class/backlight/$x" ]; then
		device="/sys/class/backlight/$x"
		break
	fi
done

if [ -z "$device" ]; then
	exit 1
fi

max=`cat $device/max_brightness`
step=$(($max/15))
current=`cat $device/brightness`

case "$1" in
	"up")
		new=$(($current+$step))
		if [ $new -gt $max ]; then
			new=$max
		fi
		echo $new > $device/brightness
		;;
	"down")
		new=$(($current-$step))
		if [ $new -lt 1 ]; then
			new=1
		fi
		echo $new > $device/brightness
		;;
esac
