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

################ Apply Patches Below ####################

repo start auto device/samsung/epicmtd
cdv device/samsung/epicmtd
cdb

repo start auto frameworks/base 
cdv frameworks/base
cdb

repo start auto kernel/samsung/victory
cdv kernel/samsung/victory
cdb

repo start auto packages/apps/Phone
cdv packages/apps/Phone
echo "### Phone: add voicemail notification setting http://review.cyanogenmod.com/#change,13706"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_packages_apps_Phone refs/changes/06/13706/6 && git cherry-pick FETCH_HEAD
echo "### Phone: Roaming Fix http://review.cyanogenmod.com/#/c/12624/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_packages_apps_Phone refs/changes/24/12624/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto packages/providers/MediaProvider
cdv packages/providers/MediaProvider
echo "### Media Provider: Fix http://review.cyanogenmod.com/#/c/13251/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_packages_providers_MediaProvider refs/changes/51/13251/1 && git cherry-pick FETCH_HEAD
cdb

###Added for AOKP###

#repo start auto vendor/aokp
#cdv vendor/aokp
#echo "### Vendor Menu and Setup http://gerrit.sudoservers.com:8080/#/c/26/"
#git fetch http://gerrit.sudoservers.com:8080/AOKP/vendor_aokp refs/changes/26/26/2 && git cherry-pick FETCH_HEAD
#cdv


repo start auto vendor/samsung
cdv vendor/samsung
echo "### Samsung device proprietaries http://gerrit.sudoservers.com:8080/#/c/36/"
git fetch http://gerrit.sudoservers.com:8080/AOKP/vendor_samsung refs/changes/36/36/1 && git cherry-pick FETCH_HEAD
cdb

##### SUCCESS ####
SUCCESS=true
exit 0