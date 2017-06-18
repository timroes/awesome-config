#! /bin/bash

TAG='awesome(pointing-devices)'

# This script requires xinput to be installed.
command -v xinput >/dev/null 2>&1 || exit 1

touchpad=`xinput list | grep -i "Synaptics TouchPad" | sed -n 's/.*id=\([0-9]*\).*/\1/p'`

# If this device has a Synaptics TouchPad set some reasonable values for it
if [ "$touchpad" ]; then
	logger -t $TAG "Setting properties for input device $touchpad"
	# Enable Palm detection to prevent moving mouse when whole palm is on the touchpda
	xinput set-prop $touchpad 'Synaptics Palm Detection' 1
	# Set the dimensions and pressures of the palm detection
	xinput set-prop $touchpad 'Synaptics Palm Dimensions' 5 40
	# Enable two finger scrolling on both axises
	xinput set-prop $touchpad 'Synaptics Two-Finger Scrolling' 1 1
	# Disable tabing unless two and three finger tabs
	# Values are tab into: RT, RB, LT, LB, 1finger, 2finger, 3finger
	xinput set-prop $touchpad 'Synaptics Tap Action' 0 0 0 0 0 3 2

	# Also activate syndaemon if it is installed and hasn't been activated yet
	command -v syndaemon > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		logger -t $TAG "syndaemon not found on system, install it for better touchpad behaviour."
	else
		if [ ! `pidof syndaemon` ]; then
			logger -t $TAG "Starting syndaemon."
			syndaemon -i 0.9 -d -k
		fi
	fi
fi

trackpoint=`xinput list | grep -i "IBM TrackPoint" | sed -n 's/.*id=\([0-9]*\).*/\1/p'`
# If the device has a trackpoint configure it
if [ "$trackpoint" ]; then
	# Enable emulating a mouse wheel
	xinput set-prop $trackpoint 'Evdev Wheel Emulation' 1
	# Use middle mouse button for wheel emulation
	xinput set-prop $trackpoint 'Evdev Wheel Emulation Button' 2
	# Emulate all 4 scroll axises
	xinput set-prop $trackpoint 'Evdev Wheel Emulation Axes' 6 7 4 5
fi

# Make external mouse left handed
# TODO: Maybe there is a better way which also survives plugins/plugouts and can be configured
mouse=$(xinput list --name-only | grep "Optical Mouse")
xinput set-button-map "$mouse" 3 2 1
