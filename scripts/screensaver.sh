#! /bin/bash

# This script pauses running screensavers or resume them again.
# It will try to find several installed screensaver software
# and dis/enable xserver's own screen blanking and display
# energy saving.

case "$1" in
	"pause")
		# Disables screen blanking of xserver
		xset s off
		# Disables DPMS (energy star) feature
		xset -dpms
		# Xautolock is available disable it
		xautolock -disable
		;;
	"resume")
		# Reset the screensaver values to default
		xset s default
		# Enable DPMS again
		xset +dpms
		# Enable xautolock again
		xautolock -enable
		;;
	*)
		echo "Specify 'pause' or 'resume' as first parameter."
		;;
esac
