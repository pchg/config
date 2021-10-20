#!/bin/bash
#
#

export SMB_MOUNT_OPTIONS="rw,isocharset=utf8,shortname=mixed"
export FILE_SHARE="~/share.txt"
export MOUNT_POINT=`mount | grep smb`

case "$1" in
	 "start")
awk -- '\
BEGIN {FS=":";ok=1}\
{\
	isIn = index(ENVIRON["MOUNT_POINT"],$1);\
	print "Mount point: " $1 " Source: " $2 " isIn:" isIn;\
	if (ok==1 && isIn==0)\
	{\
	n=split($2, server, "/"); \
	strping = sprintf("ping -qc 2 %s >/dev/null", server[3]); \
	print strping; \
	if (system(strping)==0)\
	{
		str = sprintf("mount -tsmb -o %s,username=`cat %s`,uid=%s,gid=%s %s %s", ENVIRON["SMB_MOUNT_OPTIONS"], $5, $3, $4, $2, $1);\
		print str; \
		if (system(str)!=0) {ok=0};\
	}\
	}\
	else\
	{\
		print $2 " already mounted";\
	}\
	}' $FILE_SHARE
	;;
	"stop")
	awk -- '\
		BEGIN {FS=":"}\
		{\
			str = sprintf("umount %s", $1);\
			system(str); \
		}' $FILE_SHARE
	;;
esac
