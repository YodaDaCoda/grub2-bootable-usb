#!/bin/bash

if [[ "$(id -un)" != "$(logname)" ]]; then
	echo "Got root."
else
	echo "This script requires root."
	sudo bash "$0" $@
	exit
fi

path=$(echo $0 | rev | cut -d"/" -f2- | rev)

chmod 644 *.iso *.txt *.img *.bin *.cfg
chmod 755 *.sh
rm *.*~

distro="Ubuntu"
release="saucy"
fn="ubuntu-testing.iso"

$path/zsync -i "$fn" -o "$fn" "http://cdimage.ubuntu.com/daily-live/current/$release-desktop-amd64.iso.zsync"

e=$?
if [ $e -ne 0 ]; then
	echo "Something broke."
	if [ $e -eq 3 ]; then
		echo "Probably a 404. Maybe there is a new release of $distro available?"
	fi
elif [ -f "$fn.zsync-old" ]; then
	rm "$fn.zsync-old"
elif [ -f "$fn.zs-old" ]; then
	rm "$fn.zs-old"
fi

