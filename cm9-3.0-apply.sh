#!/bin/bash

unset SUCCESS
on_exit() {
  if [ -z "$SUCCESS" ]; then
    echo "ERROR: $0 failed.  Please fix the above error."
    exit 1
  else
    echo "SUCCESS: $0 has completed."
    exit 0
  fi
}
trap on_exit EXIT

http_patch() {
  PATCHNAME=$(basename $1)
  curl -L -o $PATCHNAME -O -L $1
  cat $PATCHNAME |patch -p1
  rm $PATCHNAME
}

wget_patch() {
  PATCHNAME=$(basename $1)
  wget $1
  cat $PATCHNAME |patch -p1
  rm $PATCHNAME
}

# Change directory verbose
cdv() {
  echo
  echo "*****************************"
  echo "Current Directory: $1"
  echo "*****************************"
  cd $BASEDIR/$1
}

# Change back to base directory
cdb() {
  cd $BASEDIR
}

# Sanity check
if [ -d ../.repo ]; then
  cd ..
fi
if [ ! -d .repo ]; then
  echo "ERROR: Must run this script from the base of the repo."
  SUCCESS=true
  exit 255
fi

# Save Base Directory
BASEDIR=$(pwd)

# Abandon auto topic branch
repo abandon auto
set -e

################ Apply Patches Below ####################

repo start auto device/samsung/epicmtd
cdv device/samsung/epicmtd
echo "### cm9-3.0-apply.sh: epicmtd: Temporary patch for kernel-3.0.x testing (DO NOT COMMIT) http://review.cyanogenmod.com/#/c/15585/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_device_samsung_epicmtd refs/changes/85/15585/1 && git cherry-pick FETCH_HEAD
echo "### Update init.victory.usb.rc to fix adb, etc. for kernel-3.0.x (DO NOT COMMIT) http://review.cyanogenmod.com/#/c/15928/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_device_samsung_epicmtd refs/changes/28/15928/1 && git cherry-pick FETCH_HEAD
echo "### epicmtd: Permission updates for kernel-3.0.x (DO NOT COMMIT) http://review.cyanogenmod.com/16080"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_device_samsung_epicmtd refs/changes/80/16080/3 && git cherry-pick FETCH_HEAD
cdb

repo start auto frameworks/base 
cdv frameworks/base
echo "### Fixes to ensure keyboard backlight is lit when the keyboard is visible. http://review.cyanogenmod.com/18065"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/65/18065/1 && git cherry-pick FETCH_HEAD
cdb

#repo start auto kernel/samsung/victory3/Kernel
#cdv kernel/samsung/victory3/Kernel
#cdb

##### SUCCESS ####
SUCCESS=true
exit 0
