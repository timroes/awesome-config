#! /bin/bash

TAG='awesome(pointing-devices)'

# This script requires xinput to be installed.
command -v xinput >/dev/null 2>&1 || exit 1

touchpad=$(xinput list --name-only | grep -i "Synaptics TouchPad")

# If this device has a Synaptics TouchPad set some reasonable values for it
if [ "$touchpad" ]; then
	logger -t $TAG "Setting properties for input device $touchpad"
	# Enable Palm detection to prevent moving mouse when whole palm is on the touchpad
	xinput set-prop "$touchpad" 'libinput Click Method Enabled' 0 1
	# Disable touching on the pad
	xinput set-prop "$touchpad" 'libinput Tapping Enabled' 0
	# Set acceleration of trackpad
	xinput set-prop "$touchpad" 'libinput Accel Speed' 0.7
fi

# Make external mouse left handed
xinput list --id-only | while IFS= read -r line; do
	left_handed="$(xinput list-props $line | grep -i "left handed enabled (")"
	if [[ "$left_handed" ]]; then
		[[ ${left_handed,,} =~ "left handed enabled ("([0-9]+)")" ]]
		logger -t $TAG "Switching input device $line to left handed"
		xinput set-prop $line ${BASH_REMATCH[1]} 1
	fi
done
