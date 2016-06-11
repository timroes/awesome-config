#! /bin/bash

command -v luarocks >/dev/null 2>&1 || { echo "Please install luarocks on your system and run this script again."; exit 1; }

dependencies=(
	'luafilesystem'
	'lyaml'
	'inifile'
	# 'lgi' # not required since awesome depends on it
)

for dep in "${dependencies[@]}"
do
	echo "Install dependency $dep..."
	luarocks --local install $dep
	if [ $? -eq 0 ]; then
		echo "[done]"
	else
		echo "[failed]"
		echo "See build output above, fix the problem and then run this script again."
		exit 1
	fi
done
