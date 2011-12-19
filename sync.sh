#!/bin/sh

set -e

SCRIPT_DIR=$( (cd -P $(dirname $0) && pwd) )
DIST_DIR_BASE=${DIST_DIR_BASE:="$SCRIPT_DIR/dist"}

if [ -d ffmpeg ]
then
  echo "Found ffmpeg source directory, no need to fetch from git..."
else
  echo "Fetching ffmpeg from git://git.videolan.org/ffmpeg.git..."
  git submodule update --init ffmpeg
fi

#ARCHS=${ARCHS:-"armv6 armv7 i386"}
ARCHS=${ARCHS:-"armv7 i386"}

for ARCH in $ARCHS
do
    FFMPEG_DIR=ffmpeg-$ARCH
    if [ -d $FFMPEG_DIR ]
    then
      echo "Removing old directory $FFMPEG_DIR"
      rm -rf $FFMPEG_DIR
    fi
    echo "Copying source for $ARCH to directory $FFMPEG_DIR"
    cp -a ffmpeg $FFMPEG_DIR
done
