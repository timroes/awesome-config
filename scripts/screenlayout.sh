#! /bin/bash

outputs=($(/usr/bin/xrandr | grep -oE '^(.*) connected' | cut -f1 -d' '))
prefInternal=$(/usr/bin/xrandr | grep -E '^ .*\+' | head -n 1 | cut -d' ' -f4)

function resetInternal() {
	/usr/bin/xrandr --output ${outputs[0]} --mode $prefInternal --scale-from $prefInternal --scale $prefInternal
}

case "$1" in
	"notebook")
		/usr/bin/xrandr --output ${outputs[1]} --off
		resetInternal
		;;
	"clone")
		/usr/bin/xrandr --output ${outputs[1]} --auto --output ${outputs[0]} --auto --same-as ${outputs[1]}
		prefExternal=$(/usr/bin/xrandr | grep "${outputs[1]}" -A20 | grep -E '^ .*\*' | head -n 1 | cut -d' ' -f4)
		/usr/bin/xrandr --output ${outputs[0]} --mode $prefInternal --scale $prefInternal --scale-from $prefExternal
		;;
	"extend")
		resetInternal
		/usr/bin/xrandr --output ${outputs[1]} --auto --output ${outputs[0]} --auto --left-of ${outputs[1]}
		;;
	"external")
		/usr/bin/xrandr --output ${outputs[1]} --auto --output ${outputs[0]} --off
		;;
	"disconnect")
		resetInternal
		# Reset framebuffer size (to prevent too large fb size on too small screen)
		res=$(xrandr | grep '*' | cut -d' ' -f4)
		/usr/bin/xrandr --fb $res
		;;
esac
