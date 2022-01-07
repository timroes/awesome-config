#! /bin/bash	

# For this script to work make sure ../configs/global/udev.backlight.rules is copied to the appropriate place
# and the user is in the video group.

device=$1
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