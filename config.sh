#!/bin/bash

FFMPEG_VER=1.2
IOSSDK_VER=6.1
ARCHS="armv6 armv7 armv7s i386"

# IOSSDKVERSION=5.1
# ARCHS=${ARCHS:-"armv6 armv7 i386"}

remove_arch() {
    OLD_ARCHS="$ARCHS"
    NEW_ARCHS=""
    REMOVAL="$1"

    for ARCH in $OLD_ARCHS; do
        if [ "$ARCH" != "$REMOVAL" ] ; then
            NEW_ARCHS="$NEW_ARCHS $ARCH"
        fi
    done
	
	ARCHS=$NEW_ARCHS
}

CHECK=`echo $IOSSDK_VER '>= 6.0' | bc -l`
if [ "$CHECK" = "0" ] ; then
    remove_arch "armv7s"
fi

CHECK=`echo $IOSSDK_VER '< 6.0' | bc -l`
if [ "$CHECK" = "0" ] ; then
    remove_arch "armv6"
fi

echo 'Architectures to build:' $ARCHS
    


