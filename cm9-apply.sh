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
git fetch http://review.cyanogenmod.com/CyanogenMod/android_device_samsung_epicmtd refs/changes/21/15421/2 && git cherry-pick FETCH_HEAD
cdb

repo start auto frameworks/base 
cdv frameworks/base
echo "### Patch: CDMA 1 signal bar threshold s/100/105/ to match Samsung"
http_patch http://asgard.ancl.hawaii.edu/~warren/testonly-cdma-1bar-105-dBm-v3.patch
git add telephony/java/android/telephony/SignalStrength.java
git commit -m "DO NOT COMMIT TO GERRIT - need to make into config.xml option for upstream"
cdb

repo start auto kernel/samsung/victory
cdv kernel/samsung/victory
#echo "### Epicmtd: reduce framebuffer NR size to 2 and frees 7mb to userspace http://review.cyanogenmod.com/#change,14386"
#git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_kernel_samsung_victory refs/changes/86/14386/1 && git cherry-pick FETCH_HEAD
echo "### Test with CONFIG_FB_S3C_NR_BUFFERS=6 since =2 was rejected (read above gerrit)"
http_patch http://asgard.ancl.hawaii.edu/~warren/test-CONFIG_FB_S3C_NR_BUFFERS-6.patch
git add Kernel/arch/arm/configs/cyanogenmod_epicmtd_defconfig
git commit -m "DO NOT COMMIT TO GERRIT - test CONFIG_FB_S3C_NR_BUFFERS=6"
echo "### Add sysfs control for capacitive backlights. http://review.cyanogenmod.com/#/c/15420"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_kernel_samsung_victory refs/changes/20/15420/5 && git cherry-pick FETCH_HEAD
echo "### Call cpufreq_update_policy on DVFS events and force SLEEP_FREQ on suspend. http://review.cyanogenmod.com/15490"
git fetch http://r.cyanogenmod.com/CyanogenMod/android_kernel_samsung_victory refs/changes/90/15490/2 && git cherry-pick FETCH_HEAD
echo "### Use DVFS locks instead of cpufreq policy mangling in pvr. http://review.cyanogenmod.com/15484"
git fetch http://r.cyanogenmod.com/CyanogenMod/android_kernel_samsung_victory refs/changes/84/15484/2 && git cherry-pick FETCH_HEAD
echo "### Add dvfs_printk_mask sysfs attribute to mask printing of DVFS lock events. http://review.cyanogenmod.com/15535"
git fetch http://r.cyanogenmod.com/CyanogenMod/android_kernel_samsung_victory refs/changes/35/15535/2 && git cherry-pick FETCH_HEAD
echo "### Add 1.2GHz overclock, disabled by default. http://review.cyanogenmod.com/15446"
git fetch http://r.cyanogenmod.com/CyanogenMod/android_kernel_samsung_victory refs/changes/46/15446/2 && git cherry-pick FETCH_HEAD
cdb


repo start auto packages/apps/Phone
cdv packages/apps/Phone
echo "### Phone: add voicemail notification setting http://review.cyanogenmod.com/#change,13706"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_packages_apps_Phone refs/changes/06/13706/6 && git cherry-pick FETCH_HEAD
cdb

repo start auto packages/apps/Camera
cdv packages/apps/Camera
echo "### Camera: Use popup settings instead of knobs http://review.cyanogenmod.com/#/c/15356/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_packages_apps_Camera refs/changes/56/15356/5 && git cherry-pick FETCH_HEAD
cdb

repo start auto packages/apps/Settings
cdv packages/apps/Settings
echo "### Settings: Use Holo theme for ActivityPicker Dialog http://review.cyanogenmod.com/#/c/15035/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_packages_apps_Settings refs/changes/35/15035/2 && git cherry-pick FETCH_HEAD
cdb

##### SUCCESS ####
SUCCESS=true
exit 0
