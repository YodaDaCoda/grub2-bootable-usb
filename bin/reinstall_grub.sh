#!/bin/bash
#YOU NEED TO USE THE LINE BELOW TO REMOUNT THE DRIVE TO RUN THIS SHELL SCRIPT
#(change mount point / device as required)
#sudo umount /media/0064f27c-0b76-4360-bee9-8450c694e9ee
#sudo mount -o rw,nosuid,uid=$(id -u),gid=$(id -g) -t vfat /dev/sdc1 /media/0064f27c-0b76-4360-bee9-8450c694e9ee

#This is the only part you need to change.
#It can be found from blkid, or using the command below, inserting the appropriate mount point
#df 2>/dev/null | grep [mountpoint] | awk '{print $1}' | xargs -I % blkid % | awk '{print $3}' | sed 's/.*\"\(.*\)\"/\1/'
UUID="22C63AE3C63AB6BF"

function quit {
	#if not run from inside terminal, prompt to exit
	if [ "$GRAND_PARENT_NAME" != "gnome-terminal" ] && [ "$GRAND_PARENT_NAME" != "bash" ] && [ "$GRAND_PARENT_NAME" != "xterm" ] && [ "$GRAND_PARENT_NAME" != "/usr/bin/konsole" ]; then
		read -p "Press enter to exit."
	fi
	exit
}

GRAND_PARENT_NAME=$(ps -ef | awk '{ print $2 " " $3 " " $8 }' | grep -P "^`ps -ef | awk '{ print $2 " " $3 " " $8 }' | grep -P "^$PPID " | awk '{ print $2 }'` " | awk '{ print $3 }')

echo $GRAND_PARENT_NAME

CD=`dirname $0`

mkdir $CD/../grub/

cp -f $CD/../cfg/grub.cfg			$CD/../grub/grub.cfg
cp -f $CD/../cfg/grub-amd64.cfg		$CD/../grub/grub-amd64.cfg
cp -f $CD/../cfg/grub-i386.cfg		$CD/../grub/grub-i386.cfg

sed -i "s/###ROOTUUID###/$UUID/" $CD/../grub/grub.cfg

partition=`sudo blkid -U $UUID`
dev=${partition%[[:digit:]]}
mountpoint=`grep "$partition" /etc/mtab | cut -d" " -f2`
#mountpoint=${mountpoint##* }

if [ "$partition" == "" ]; then
	quit
fi

echo ""
echo "Processing UUID $UUID ..."
echo ""
echo "Device:     $dev"
echo "Partition:  $partition"
echo "MountPoint: $mountpoint"
echo ""

echo "Installing..."
sudo grub-install --root-directory=$mountpoint --boot-directory=$mountpoint/boot $dev

echo ""
echo "Script finished."
quit
