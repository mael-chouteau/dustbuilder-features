#!/bin/ash
# Author: Dennis Giese [dgiese at dontvacuum.me]
# Copyright 2020 by Dennis Giese
#
# Intended to work on mc1808,p2008,p2009,p2041
#
DEVICEMODEL="CHANGEDEVICEMODELCHANGE"

echo "---------------------------------------------------------------------------"
echo " Dreame manual Firmware installer"
echo " Copyright 2020 by Dennis Giese [dgiese at dontvacuum.me]"
echo " Intended to work on mc1808,p2008,p2009,p2041"
echo " Version: ${DEVICEMODEL}"
echo " Use at your own risk"
echo "---------------------------------------------------------------------------"

grep "model=${DEVICEMODEL}" /data/config/miio/device.conf
if [ $? -eq 1 ]; then
	echo "(!!!) It seems you are trying to run the installer on a $(sed -rn 's/model=(.*)/\1/p' /tmp/config/miio/device.conf) instead of ${DEVICEMODEL}."
	exit 1
fi

echo "check image file size"
maximumsize=30000000
minimumsize=20000000
# maxsizeplaceholder
# minsizeplaceholder
actualsize=$(wc -c < ./rootfs.img)
if [ "$actualsize" -ge "$maximumsize" ]; then
	echo "(!!!) rootfs.img looks to big. The size might exceed the available space on the flash. Aborting the installation"
	exit 1
fi
if [ "$actualsize" -le "$minimumsize" ]; then
	echo "(!!!) rootfs.img looks to small. Maybe something went wrong with the image generation. Aborting the installation"
	exit 1
fi

if [[ -f ./boot.img ]]; then
	if [[ -f ./rootfs.img ]]; then
		if [[ -f ./mcu.bin ]]; then
			echo "Checking integrity"
			md5sum -c firmware.md5sum
			if [ $? -ne 0 ]; then
				echo "(!!!) integrity check failed. Firmware files are damaged. Please re-download the firmware. Aborting the installation"
				exit 1
			fi

			echo "Start installation ... the robot will automatically reboot after the installation is complete"

			mkdir -p /tmp/update
			mv ./boot.img /tmp/update/
			mv ./rootfs.img /tmp/update/
			mv ./mcu.bin /tmp/update/
			
			avacmd ota  '{"type": "ota", "cmd": "report_upgrade_status", "status": "AVA_UNPACK_OK", "result": "ok"}'
		else
			echo "(!!!) mcu.bin not found"
		fi
	else
		echo "(!!!) rootfs.img not found"
	fi
else
	echo "(!!!) boot.img not found"
fi
