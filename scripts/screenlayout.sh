#! /bin/bash

outputs=($(/usr/bin/xrandr | grep -oE '^(.*) connected' | cut -f1 -d' '))

case "$1" in
	"notebook")
		/usr/bin/xrandr --output ${outputs[0]} --auto --output ${outputs[1]} --off
		;;
	"clone")
		/usr/bin/xrandr --output ${outputs[1]} --auto --output ${outputs[0]} --auto --same-as ${outputs[1]}
		;;
	"extend")
		/usr/bin/xrandr --output ${outputs[1]} --auto --output ${outputs[0]} --auto --left-of ${outputs[1]}
		;;
	"external")
		/usr/bin/xrandr --output ${outputs[1]} --auto --output ${outputs[0]} --off
		;;
	"disconnect")
		/usr/bin/xrandr --output ${outputs[0]} --off
		/usr/bin/xrandr --output ${outputs[0]} --auto
		;;
esac
