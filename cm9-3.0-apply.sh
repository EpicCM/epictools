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

repo start auto bootable/recovery
cdv bootable/recovery
echo "### recovery: Allow key to repeat on hold. http://review.cyanogenmod.com/#/c/15865/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_bootable_recovery refs/changes/65/15865/14 && git cherry-pick FETCH_HEAD
cdb

repo start auto device/samsung/epicmtd
cdv device/samsung/epicmtd
echo "### epicmtd: Enable CWM repeatable keys http://review.cyanogenmod.com/#/c/16037/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_device_samsung_epicmtd refs/changes/37/16037/1 && git cherry-pick FETCH_HEAD
echo "### Change wifi module location to ease kernel 3.0.x testing (DO NO COMMIT) http://review.cyanogenmod.com/#/c/16002/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_device_samsung_epicmtd refs/changes/02/16002/1 && git cherry-pick FETCH_HEAD
echo "### cm9-3.0-apply.sh: epicmtd: Temporary patch for kernel-3.0.x testing (DO NOT COMMIT) http://review.cyanogenmod.com/#/c/15585/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_device_samsung_epicmtd refs/changes/85/15585/1 && git cherry-pick FETCH_HEAD
echo "### Update init.victory.usb.rc to fix adb, etc. for kernel-3.0.x (DO NOT COMMIT) http://review.cyanogenmod.com/#/c/15928/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_device_samsung_epicmtd refs/changes/28/15928/1 && git cherry-pick FETCH_HEAD
echo "### epicmtd: Permission updates for kernel-3.0.x (DO NOT COMMIT) http://review.cyanogenmod.com/16080"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_device_samsung_epicmtd refs/changes/80/16080/2 && git cherry-pick FETCH_HEAD
cdb

repo start auto frameworks/base 
cdv frameworks/base
echo "### telephony: CDMA signal bar threshold s/100/105/ to match Samsung's behavior (DO NOT COMMIT) http://review.cyanogenmod.com/#/c/15580/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/80/15580/5 && git cherry-pick FETCH_HEAD
cdb

#repo start auto kernel/samsung/victory3/Kernel
#cdv kernel/samsung/victory3/Kernel
#cdb

repo start auto packages/apps/Phone
cdv packages/apps/Phone

cdb

repo start auto vendor/cm
cdv vendor/cm
echo "### Simplifly ROM filename, add CM_EXPERIMENTAL, datestamp UNOFFICIAL, remove some dead code. http://review.cyanogenmod.com/#/c/15662/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_vendor_cm refs/changes/62/15662/4 && git cherry-pick FETCH_HEAD
cdb

##### SUCCESS ####
SUCCESS=true
exit 0
