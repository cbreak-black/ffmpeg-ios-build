#!/bin/sh

PLATFORMBASE=$(xcode-select -print-path)"/Platforms"
IOSSDKVERSION=5.0

set -e

SCRIPT_DIR=$( (cd -P $(dirname $0) && pwd) )
DIST_DIR_BASE=${DIST_DIR_BASE:="$SCRIPT_DIR/dist"}

if [ ! -d ffmpeg ]
then
  echo "ffmpeg source directory does not exist, run sync.sh"
fi

#ARCHS=${ARCHS:-"armv6 armv7 i386"}
ARCHS=${ARCHS:-"armv7 i386"}

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
            EXTRA_FLAGS="--cpu=arm1176jzf-s"
            EXTRA_CFLAGS=""
            PLATFORM="${PLATFORMBASE}/iPhoneOS.platform"
            IOSSDK=iPhoneOS${IOSSDKVERSION}
            ;;
        armv7)
            EXTRA_FLAGS="--cpu=cortex-a8 --enable-pic"
            EXTRA_CFLAGS="-mfpu=neon"
            PLATFORM="${PLATFORMBASE}/iPhoneOS.platform"
            IOSSDK=iPhoneOS${IOSSDKVERSION}
            ;;
        i386)
            EXTRA_FLAGS="--enable-pic"
            EXTRA_CFLAGS=""
            PLATFORM="${PLATFORMBASE}/iPhoneSimulator.platform"
            IOSSDK=iPhoneSimulator${IOSSDKVERSION}
            ;;
        *)
            echo "Unsupported architecture ${ARCH}"
            exit 1
            ;;
    esac

    echo "Configuring ffmpeg for $ARCH..."
    ./configure \
    --prefix=$DIST_DIR \
    --enable-cross-compile --target-os=darwin --arch=$ARCH \
    --cross-prefix="${PLATFORM}/Developer/usr/bin/" \
    --sysroot="${PLATFORM}/Developer/SDKs/${IOSSDK}.sdk" \
    --extra-ldflags=-L${PLATFORM}/Developer/SDKs/${IOSSDK}.sdk/usr/lib/system \
    --disable-bzlib \
    --disable-doc \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffserver \
    --disable-ffprobe \
    --as="gas-preprocessor.pl ${PLATFORM}/Developer/usr/bin/as" \
    --extra-ldflags="-arch $ARCH" \
    --extra-cflags="-arch $ARCH $EXTRA_CFLAGS" \
    --extra-cxxflags="-arch $ARCH" \
    $EXTRA_FLAGS

    echo "Installing ffmpeg for $ARCH..."
    make clean
    make -j8 V=1
    make install

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
