#! /bin/bash

command -v luarocks >/dev/null 2>&1 || { echo "Please install luarocks on your system and run this script again."; exit 1; }

dependencies=(
	'luafilesystem'
	# 'lgi' # not required since awesome depends on it
)

for dep in "${dependencies[@]}"
do
	echo "Install dependency $dep..."
	luarocks --local install $dep
	echo "[done]"
done
