#! /bin/bash

# This should be applied to the following udev rules:
# ACTION=="change",SUBSYSTEM=="drm",HOTPLUG=="1",RUN+="/path/to/this/script"

DISPLAY=:0
xuser=$(who | sed -ne "s/^\([^ ]*\)[ ]*:0.*/\1/p")

xrandout=`su -l -c "DISPLAY=:0 xrandr | grep ' connected' | wc -l" $xuser`

if [ "$xrandout" == "1" ]; then
	dbus-send --system /de/timroes/displaywidget de.timroes.displaywidget.Unplugged
else 
	dbus-send --system /de/timroes/displaywidget de.timroes.displaywidget.Plugged
fi
