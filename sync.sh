#!/bin/sh

set -e

source config.sh

SCRIPT_DIR=$( (cd -P $(dirname $0) && pwd) )
DIST_DIR_BASE=${DIST_DIR_BASE:="$SCRIPT_DIR/dist"}

git submodule update --init gas-preprocessor
cd gas-preprocessor
git checkout master
git pull 
cd ..

git submodule update --init ffmpeg
cd ffmpeg
git checkout release/${FFMPEG_VER}
git pull 
cd ..

for ARCH in $ARCHS
do
    FFMPEG_DIR=ffmpeg-$ARCH
    echo "Syncing source for $ARCH to directory $FFMPEG_DIR"
    rsync ffmpeg/ $FFMPEG_DIR/ --exclude '.*' -a --delete
    if [ -d patches ]
    then
        echo "Applying patches to source in directory $FFMPEG_DIR"
        git apply -v --directory=$FFMPEG_DIR patches/*
    fi
done
