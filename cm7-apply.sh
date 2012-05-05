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
#Addition of OC
echo 'Adding 1.2ghz OC http://review.cyanogenmod.com/#/c/14697/'
git fetch http://review.cyanogenmod.com/CyanogenMod/android_kernel_samsung_victory refs/changes/72/15072/1 && git cherry-pick FETCH_HEAD

cdb
##### SUCCESS ####
SUCCESS=true
exit 0
