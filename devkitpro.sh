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
LOGFILE=$DEVKITPRO_PATH'/install.log'

function msg() {
    echo \-\> $1
    echo \-\> $1 >>$LOGFILE
}

function error() {
    echo \-\>ERROR: $1 >&2
    echo \-\>ERROR: $1 >>$LOGFILE
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

function checkForErrors() {
    if [ $? -ne 0 ]
    then
        error "Unexpected error: check $LOGFILE for details."
    fi
}

echo -n >$LOGFILE

echo
msg "Building directory tree..."
createDir $DEVKITPRO_PATH

createDir $DOWNLOAD_CACHE_PATH

createDir $LIBNDS_PATH
createDir $NOCASHGBA_PATH

pushd $DOWNLOAD_CACHE_PATH >>$LOGFILE

echo
echo >>$LOGFILE
msg "Downloading files..."
download $DEVKITARM_URL
download $PALIB_URL
download $LIBNDS_URL
download $LIBFAT_URL
download $DSWIFI_URL
download $NOCASHGBA_URL

echo
echo >>$LOGFILE
msg "Extracting archives..."

msg " ...devkitARM"
tar xvf $(stripURL $DEVKITARM_URL) -C $DEVKITPRO_PATH >>$LOGFILE
checkForErrors

msg " ...PAlib"
7zr x -o$PALIB_PATH -y $(stripURL $PALIB_URL) >>$LOGFILE
checkForErrors

msg " ...libnds"
tar xvf $(stripURL $LIBNDS_URL) -C $LIBNDS_PATH >>$LOGFILE
checkForErrors

msg " ...libfat"
tar xvf $(stripURL $LIBFAT_URL) -C $LIBNDS_PATH >>$LOGFILE
checkForErrors

msg " ...dswifi"
tar xvf $(stripURL $DSWIFI_URL) -C $LIBNDS_PATH >>$LOGFILE
checkForErrors

msg " ...dswifi"
unzip $(stripURL $NOCASHGBA_URL) -d $NOCASHGBA_PATH -o >>$LOGFILE

popd >>$LOGFILE

echo
echo "devkitPRO installed successfully!"
