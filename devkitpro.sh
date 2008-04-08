#!/bin/bash

# Edit the following properties to your own taste:
#  NOTE: PATHECTORY PATHS MUST BE ABSOLUTE
DEVKITPRO_PATH='/tmp/devkitpro'
LIBNDS_PATH=$DEVKITPRO_PATH'/libnds'
NOCASHGBA_PATH=$DEVKITPRO_PATH'/no\$gba'
PALIB_PATH=$DEVKITPRO_PATH

# File URLS:
DEVKITARM_URL="http://superb-east.dl.sourceforge.net/sourceforge/devkitpro/devkitARM_r21-linux.tar.bz2"
PALIB_URL="http://palib.info/downloads/Beta/PALib_CommunityUpdate_BETA-080203.7z"
LIBNDS_URL="http://internap.dl.sourceforge.net/sourceforge/devkitpro/libnds-20071023.tar.bz2"
LIBFAT_URL="http://internap.dl.sourceforge.net/sourceforge/devkitpro/libfat-nds-20070127.tar.bz2"
DSWIFI_URL="http://internap.dl.sourceforge.net/sourceforge/devkitpro/dswifi-0.3.4.tar.bz2"
NOCASHGBA_URL="http://nocash.emubase.de/no\$gba-w.zip"
DOWNLOAD_CACHE_PATH=$HOME'/.devkitpro_cache'

function msg() {
    echo \-\>$1
}

function error() {
    echo \-\>ERROR: $1 >&2
    exit
}

function download() {
    if [ ! -e $(stripURL $1) ]
    then
        wget -q -c $1
        if [ $? -ne 0 ]
        then
            error "Failed to download file: $1."
        fi
    else
        msg "File already exists, not downloading: $(stripURL $1)"
    fi
}

function stripURL() {
    echo ${1:$(expr "$1" : '.*/')}
}

function createDir() {
    if [ ! -d $1 ]
    then
        mkdir $1
        if [ $? -ne 0 ]
        then
            error "Could not create directory: $1"
            exit
        else
            msg "Created directory: $1"
        fi
    
    else
        msg "$1: directory alreaedy exists."
    fi
}

msg "Building directory tree..."
createDir $DEVKITPRO_PATH

createDir $DOWNLOAD_CACHE_PATH

createDir $LIBNDS_PATH
createDir $NOCASHGBA_PATH

pushd $DOWNLOAD_CACHE_PATH >/dev/null

msg "Downloading files..."
download $DEVKITARM_URL
download $PALIB_URL
download $LIBNDS_URL
download $LIBFAT_URL
download $DSWIFI_URL
download $NOCASHGBA_URL


msg "Extracting archives..."
msg "...devkitARM"
tar xf $(stripURL $DEVKITARM_URL) -C $DEVKITPRO_PATH 
msg "...PAlib"
7zr x -o $PALIB_PATH $(stripURL $PALIB_URL)
msg "...libnds"
tar xf $(stripURL $LIBNDS_URL) -C $LIBNDS_PATH 
msg "...libfat"
tar xf $(stripURL $LIBFAT_URL) -C $LIBNDS_PATH 
msg "...dswifi"
tar xf $(stripURL $DSWIFI_URL) -C $LIBNDS_PATH

popd >/dev/null
