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


repo start auto frameworks/base 
cdv frameworks/base
#echo "### Sensor: Add RotationVectorSensor2 http://review.cyanogenmod.com/#change,14609"
#git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_frameworks_base refs/changes/09/14609/1 && git cherry-pick FETCH_HEAD
echo "### Separate configuration of auto-brightness for button/keyboard backlights http://review.cyanogenmod.com/#/c/14196/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/96/14196/1 && git cherry-pick FETCH_HEAD
cdb
repo start auto kernel/samsung/victory
cdv kernel/samsung/victory
#ICS volume patch
echo 'Cherry-pick ICS speaker volume patch'
git cherry-pick 1e5a55b9d04267f4ef4288234f798df3f8989a62
#Dock audio patch
echo 'Cherry-pick dock audio ICS patch'
git cherry-pick f952cc9b6358b1af2d3425f3b3c7f24e95d6ac27
#Headset mic volume patch
echo 'Cherry-pick headset-mic volume patch, to match EL30'
git cherry-pick bdb608a3663c2a372d6b5c8e3f9eb37f17ced35a
#Enable tun
echo 'Cherry-pick tun'
git cherry-pick 6126b51da4e2402bdd519ade4a4caba5dbaa3098
#Deadlock condition fix
echo 'Fix to prevent deadlock http://review.cyanogenmod.com/#/c/14749/'
git fetch http://review.cyanogenmod.com/CyanogenMod/android_kernel_samsung_victory refs/changes/49/14749/2 && git cherry-pick FETCH_HEAD
#Addition of OC - Removed due to current incompatibilities
#echo 'Adding 1.2ghz OC http://review.cyanogenmod.com/#/c/14697/'
#git fetch http://review.cyanogenmod.com/CyanogenMod/android_kernel_samsung_victory refs/changes/97/14697/4 && git cherry-pick FETCH_HEAD

cdb
##### SUCCESS ####
SUCCESS=true
exit 0
