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

repo start auto device/samsung/epicmtd
cdv device/samsung/epicmtd
echo "### epicmtd: enable enable_vmnotif_option http://review.cyanogenmod.com/#change,13739"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_device_samsung_epicmtd refs/changes/39/13739/1 && git cherry-pick FETCH_HEAD
echo "### Add EpicParts with option to disable capacitive backlights. http://review.cyanogenmod.com/#/c/15421"
git fetch http://r.cyanogenmod.com/CyanogenMod/android_device_samsung_epicmtd refs/changes/21/15421/4 && git cherry-pick FETCH_HEAD
echo "### epicmtd: Read bt mac address from ril and setprop to our own BDADDR PATH http://review.cyanogenmod.com/#/c/15603/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_device_samsung_epicmtd refs/changes/03/15603/7 && git cherry-pick FETCH_HEAD
cdb

repo start auto frameworks/base 
cdv frameworks/base
echo "### telephony: CDMA signal bar threshold s/100/105/ to match Samsung's behavior (DO NOT COMMIT) http://review.cyanogenmod.com/#/c/15580/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/80/15580/5 && git cherry-pick FETCH_HEAD
echo "### Additional fixes for button/keyboard backlight auto-brightness. http://review.cyanogenmod.com/15726"
git fetch http://r.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/26/15726/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto kernel/samsung/victory
cdv kernel/samsung/victory
echo "### Omnibus fixes for cypress-touchkey. http://review.cyanogenmod.com/15654"
git fetch http://r.cyanogenmod.com/CyanogenMod/android_kernel_samsung_victory refs/changes/54/15654/3 && git cherry-pick FETCH_HEAD
echo "### Add sysfs control for capacitive backlights. http://review.cyanogenmod.com/#/c/15420"
git fetch http://r.cyanogenmod.com/CyanogenMod/android_kernel_samsung_victory refs/changes/20/15420/7 && git cherry-pick FETCH_HEAD
echo "### On slide open, set keyboard backlight to configured state, not always on. http://review.cyanogenmod.com/15750"
git fetch http://r.cyanogenmod.com/CyanogenMod/android_kernel_samsung_victory refs/changes/50/15750/1 && git cherry-pick FETCH_HEAD
cdb


repo start auto packages/apps/Phone
cdv packages/apps/Phone
echo "### Phone: add voicemail notification setting http://review.cyanogenmod.com/#change,13706"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_packages_apps_Phone refs/changes/06/13706/6 && git cherry-pick FETCH_HEAD
cdb

repo start auto vendor/cm
cdv vendor/cm
echo "### Simplifly ROM filename, add CM_EXPERIMENTAL, datestamp UNOFFICIAL, remove some dead code. http://review.cyanogenmod.com/#/c/15662/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_vendor_cm refs/changes/62/15662/3 && git cherry-pick FETCH_HEAD
cdb

#repo start auto packages/apps/Camera
#cdv packages/apps/Camera
#cdb

##### SUCCESS ####
SUCCESS=true
exit 0
