#!/bin/bash

if [[ "$(id -un)" != "$(logname)" ]]; then
	echo "Got root."
else
	echo "This script requires root."
	sudo bash "$0" $@
	exit
fi

path=$(echo $0 | rev | cut -d"/" -f2- | rev)

echo -n "Getting MD5 of most recent Kaspersky ISO... "
md1=$($path/curl http://rescuedisk.kaspersky-labs.com/rescuedisk/updatable/kav_rescue_10.md5.txt 2>/dev/null)
echo $md1

if [ "$md1" == "" ]; then
	echo "Failed to retrieve MD5 of most recent ISO."
	echo "Check internet connection and try again."
	exit
fi

echo -n "Generating MD5 of local Kaspersky ISO...    "
md2=$(md5sum kav_rescue_10.iso | cut -d" " -f1)
echo $md2

if [ "$md1" == "$md2" ]; then
	echo "KAV is up to date."
	echo "Nothing to do."
else
	echo "KAV is out of date"
	#read -p"Do you want to update? (y/N): " r
	#if [ "$r" == "y" ]; then
		echo "Downloading..."
		$path/curl -o "$path/kav_rescue_10.iso" "http://rescuedisk.kaspersky-labs.com/rescuedisk/updatable/kav_rescue_10.iso"
		echo "Download complete. Attempting to defrag file..."
		e4defrag $path/kav_rescue_10.iso
		echo "Done."
	#fi
fi
