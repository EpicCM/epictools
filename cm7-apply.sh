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
echo "### Separate configuration of auto-brightness for button/keyboard backlights http://review.cyanogenmod.com/#/c/14196/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/96/14196/1 && git cherry-pick FETCH_HEAD
cdb
repo start auto device/samsung/epicmtd
cdv device/samsung/epicmtd
echo 'Un-revert liblight fixes (Removed because it depends on out of tree commit above)'
git revert b11e7854b86cff56054a007a5e7fa5cf535a7004
echo 'Add EpicParts http://r.cyanogenmod.com/#/c/16043/'
git fetch http://r.cyanogenmod.com/CyanogenMod/android_device_samsung_epicmtd refs/changes/43/16043/1 && git cherry-pick FETCH_HEAD
cdb
##### SUCCESS ####
SUCCESS=true
exit 0
