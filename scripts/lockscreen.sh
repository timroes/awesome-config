#! /bin/bash

command -v import > /dev/null 2>&1
if [ $? -eq 0 ]; then
	# If imagemagick is installed, make a screenshot, pixelate it and show it as background
	filename=`mktemp --suffix .png`
	import -window root -colorspace gray $filename
	# convert $filename -colorspace gray -blur 0x12 -auto-level +depth $filename
	convert $filename -scale 4% -scale 2500% $filename
	i3lock -i "$filename" -d
	rm $filename
else
	i3lock -c BBBBBB -d
fi
