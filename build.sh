#!/bin/sh

PLATFORM=/Developer4/Platforms/iPhoneOS.platform
IOSSDK=iPhoneOS5.0

set -e

SCRIPT_DIR=$( (cd -P $(dirname $0) && pwd) )
DIST_DIR_BASE=${DIST_DIR_BASE:="$SCRIPT_DIR/dist"}

if [ -d ffmpeg ]
then
  echo "Found ffmpeg source directory, no need to fetch from git..."
else
  echo "Fetching ffmpeg from git://git.videolan.org/ffmpeg.git..."
  git clone git://git.videolan.org/ffmpeg.git
fi

ARCHS=${ARCHS:-"armv6 armv7"}

for ARCH in $ARCHS
do
    FFMPEG_DIR=ffmpeg-$ARCH
    if [ ! -d $FFMPEG_DIR ]
    then
      echo "Directory $FFMPEG_DIR does not exist, run sync.sh"
      exit 1
    fi
    echo "Compiling source for $ARCH in directory $FFMPEG_DIR"

    cd $FFMPEG_DIR

    DIST_DIR=$DIST_DIR_BASE-$ARCH
    mkdir -p $DIST_DIR

    case $ARCH in
        armv6)
            EXTRA_FLAGS="--enable-cross-compile --target-os=darwin --arch=arm --cpu=arm1176jzf-s"
            EXTRA_CFLAGS="-arch $ARCH"
            EXTRA_LDFLAGS="-arch $ARCH"
            ;;
        armv7)
            EXTRA_FLAGS="--enable-cross-compile --target-os=darwin --arch=arm --cpu=cortex-a8 --enable-pic"
            EXTRA_CFLAGS="-arch $ARCH"
            EXTRA_LDFLAGS="-arch $ARCH"
            ;;
        x86_64)
            EXTRA_CC_FLAGS="-mdynamic-no-pic"
            ;;
    esac

    echo "Configuring ffmpeg for $ARCH..."
    ./configure \
    --prefix=$DIST_DIR \
    --extra-ldflags=-L${PLATFORM}/Developer/SDKs/${IOSSDK}.sdk/usr/lib/system \
    --disable-asm \
    --disable-bzlib \
    --disable-doc \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffserver \
    --disable-ffprobe \
    --cc=${PLATFORM}/Developer/usr/bin/gcc \
    --cxx=${PLATFORM}/Developer/usr/bin/g++ \
    --as="gas-preprocessor.pl ${PLATFORM}/Developer/usr/bin/gcc" \
    --sysroot=${PLATFORM}/Developer/SDKs/${IOSSDK}.sdk \
    --extra-ldflags="$EXTRA_LDFLAGS" \
    --extra-cflags="$EXTRA_CFLAGS" \
    $EXTRA_FLAGS

    echo "Installing ffmpeg for $ARCH..."
    make clean && make -j8 && make install

    cd $SCRIPT_DIR

    if [ -d $DIST_DIR/bin ]
    then
      rm -rf $DIST_DIR/bin
    fi
    if [ -d $DIST_DIR/share ]
    then
      rm -rf $DIST_DIR/share
    fi
done
