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
repo abandon translations
set -e

############### Prep for new Kernel ##################

#echo "Removing prebuilt Kernel"
#if [ -a device/samsung/epicmtd/kernel ]
#   then
#  rm device/samsung/epicmtd/kernel
#fi
#echo "Compiling Kernel"
#cdv kernel/samsung/victory/
#. build_kernel.sh
#echo "Done, adding commits"

################ Apply Patches Below ####################

repo start auto device/samsung/epicmtd
cdv device/samsung/epicmtd
echo "### epicmtd: enable enable_vmnotif_option http://review.cyanogenmod.com/#change,13739"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_device_samsung_epicmtd refs/changes/39/13739/1 && git cherry-pick FETCH_HEAD
#echo "### Add EpicParts with option to disable capacitive backlights. http://review.cyanogenmod.com/#/c/15421"
#git fetch http://r.cyanogenmod.com/CyanogenMod/android_device_samsung_epicmtd refs/changes/21/15421/3 && git cherry-pick FETCH_HEAD
#echo "### epicmtd: Read bt mac address from ril and setprop to our own BDADDR PATH http://review.cyanogenmod.com/#/c/15603/"
#git fetch http://review.cyanogenmod.com/CyanogenMod/android_device_samsung_epicmtd refs/changes/03/15603/7 && git cherry-pick FETCH_HEAD
cdb

repo start auto frameworks/base 
cdv frameworks/base
echo "### telephony: CDMA signal bar threshold s/100/105/ to match Samsung's behavior (DO NOT COMMIT) http://review.cyanogenmod.com/#/c/15580/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/80/15580/5 && git cherry-pick FETCH_HEAD
#echo "### Additional fixes for button/keyboard backlight auto-brightness. http://review.cyanogenmod.com/15726"
#git fetch http://r.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/26/15726/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto kernel/samsung/victory
cdv kernel/samsung/victory
#echo "### Omnibus fixes for cypress-touchkey. http://review.cyanogenmod.com/15654"
#git fetch http://r.cyanogenmod.com/CyanogenMod/android_kernel_samsung_victory refs/changes/54/15654/2 && git cherry-pick FETCH_HEAD
#echo "### Add sysfs control for capacitive backlights. http://review.cyanogenmod.com/#/c/15420"
#git fetch http://r.cyanogenmod.com/CyanogenMod/android_kernel_samsung_victory refs/changes/20/15420/6 && git cherry-pick FETCH_HEAD
#echo "### On slide open, set keyboard backlight to configured state, not always on. http://review.cyanogenmod.com/15750"
#git fetch http://r.cyanogenmod.com/CyanogenMod/android_kernel_samsung_victory refs/changes/50/15750/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto packages/apps/Phone
cdv packages/apps/Phone
echo "### Phone: add voicemail notification setting http://review.cyanogenmod.com/#change,13706"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_packages_apps_Phone refs/changes/06/13706/6 && git cherry-pick FETCH_HEAD
cdb

###Added for AOKP###

repo start auto packages/apps/Settings
cdv packages/apps/Settings
echo "### Settings: Add Low Batt Pulse http://gerrit.sudoservers.com:8080/#/c/88/"
git fetch http://gerrit.sudoservers.com:8080/AOKP/packages_apps_Settings refs/changes/88/88/1 && git cherry-pick FETCH_HEAD
cdb

cdv frameworks/base
echo "### Frameworks: Keyboard fix http://gerrit.sudoservers.com:8080/#/c/25/ and http://gerrit.sudoservers.com:8080/#/c/89/"
git fetch http://gerrit.sudoservers.com:8080/AOKP/frameworks_base refs/changes/25/25/1 && git cherry-pick FETCH_HEAD
git fetch http://gerrit.sudoservers.com:8080/AOKP/frameworks_base refs/changes/89/89/3 && git cherry-pick FETCH_HEAD
cdb


repo start auto vendor/aokp
cdv vendor/aokp
echo "### Vendor Menu and Setup http://gerrit.sudoservers.com:8080/#/c/26/"
git fetch http://gerrit.sudoservers.com:8080/AOKP/vendor_aokp refs/changes/26/26/2 && git cherry-pick FETCH_HEAD
cdv


repo start auto vendor/samsung
cdv vendor/samsung
echo "### Samsung device proprietaries http://gerrit.sudoservers.com:8080/#/c/36/"
git fetch http://gerrit.sudoservers.com:8080/AOKP/vendor_samsung refs/changes/36/36/1 && git cherry-pick FETCH_HEAD
cdb

##### SUCCESS ####
SUCCESS=true
exit 0
