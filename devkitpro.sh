#!/bin/bash

#
# devkitpro.sh - simple script to set up a devkitARM/libnds/PALib/uLibrary in Linux.
# Maintained by Louis Acresti - louis.acresti@gmail.com
# Last URL update: May 31, 2010
#

# Edit the following properties to your own taste:
#  NOTE: DIRECTORY PATHS MUST BE ABSOLUTE
INSTALL_PALIB="yes"
INSTALL_ULIB="yes"
INSTALL_NOCASHGBA="yes"

DEVKITPRO_PATH=$HOME'/devkitpro'
LIBNDS_PATH=$DEVKITPRO_PATH'/libnds'
MAXMOD_PATH=$LIBNDS_PATH
DEFAULT_ARM7_PATH=$LIBNDS_PATH
LIBNDS_EX_PATH=$LIBNDS_PATH'/examples'
NOCASHGBA_PATH="$DEVKITPRO_PATH/nocashgba"
NOCASHGBA_PATH_PRINT="\$DEVKITPRO/nocashgba"
PALIB_PATH=$DEVKITPRO_PATH'/PAlib'
ULIB_PATH=$DEVKITPRO_PATH
ULIB_INC_PATH=$LIBNDS_PATH'/include/ulib'
ULIB_LIB_PATH=$LIBNDS_PATH'/lib'
DOWNLOAD_CACHE_PATH=$HOME'/.devkitpro_cache'
LOGFILE=$PWD'/devkitpro-install.log'

# File URLS:
if [ `uname -m` == "x86_64" ]
then
  DEVKITARM_URL="http://downloads.sourceforge.net/project/devkitpro/devkitARM/devkitARM_r30-x86_64-linux.tar.bz2"
else
  # Default behavior
  DEVKITARM_URL="http://downloads.sourceforge.net/project/devkitpro/devkitARM/devkitARM_r30-i686-linux.tar.bz2"
fi
DEFAULT_ARM7_URL="http://downloads.sourceforge.net/project/devkitpro/default%20arm7/default_arm7-0.5.12.tar.bz2"
PALIB_URL="http://www.palib-dev.com/PAlib0912XX_Beta.7z"
LIBNDS_URL="http://downloads.sourceforge.net/project/devkitpro/libnds/libnds-1.4.3.tar.bz2"
MAXMOD_URL="http://downloads.sourceforge.net/project/devkitpro/maxmod/maxmod%201.0.6/maxmod-nds-1.0.6.tar.bz2"
LIBNDS_EX_URL="http://downloads.sourceforge.net/project/devkitpro/examples/nds/nds-examples-20100313.tar.bz2"
LIBFAT_URL="http://downloads.sourceforge.net/project/devkitpro/libfat/libfat-nds-1.0.7.tar.bz2"
DSWIFI_URL="http://downloads.sourceforge.net/project/devkitpro/dswifi/dswifi-0.3.12.tar.bz2"
NOCASHGBA_URL="http://nocash.emubase.de/no\$gba-w.zip"
ULIB_URL="http://brunni.dev-fr.org/dl/nds/uLibrary.7z"

red='\E[31;m'
green='\E[32;m'

function msg() {
    echo \-\> $1 >>$LOGFILE
    echo -n -e "$green"
    echo -n \-\>\  
    tput sgr0
    echo $1 >&1
}

function error() {
    echo \-\>ERROR: $1 >>$LOGFILE
    echo -n -e "$red"
    echo -n \-\>ERROR:\  
    tput sgr0
    echo $1 >&2
    exit
}

function checkForErrors() {
    if [ $? -ne 0 ]
    then
        if [ -n "$1" ]
        then
            error "$@"
        else
            error "Unexpected error: check $LOGFILE for details."
        fi
        exit 1
    fi
}

function download() {
    if [ ! -e `stripURL $1` ]
    then
        wget -c $1
        checkForErrors "Failed to download file: $1."
    else
        msg "File already exists, not downloading: `stripURL $1`"
    fi
}

function stripURL() {
    echo ${1:$(expr "$1" : '.*/')}
}

function createDir() {
    if [ ! -d $1 ]
    then
        mkdir $1
        checkForErrors "Could not create directory: $1"
        msg "Created directory: $1"
    else
        msg "$1: directory already exists."
    fi
}


which 7zr &>/dev/null
checkForErrors "The program \"7zr\" is required to run this script."

which unzip &>/dev/null
checkForErrors "The program \"unzip\" is required to run this script."

which unrar &>/dev/null
checkForErrors "The program \"unrar\" is required to run this script."

echo -n >$LOGFILE

echo
msg "Building directory tree..."
createDir $DEVKITPRO_PATH

createDir $DOWNLOAD_CACHE_PATH

createDir $LIBNDS_PATH
createDir $LIBNDS_EX_PATH

createDir $ULIB_PATH
createDir $PALIB_PATH

createDir $NOCASHGBA_PATH

pushd $DOWNLOAD_CACHE_PATH >>$LOGFILE

echo
echo >>$LOGFILE
msg "Downloading files..."
download $DEVKITARM_URL
download $LIBNDS_URL
download $MAXMOD_URL
download $DEFAULT_ARM7_URL
download $LIBNDS_EX_URL
download $LIBFAT_URL
download $DSWIFI_URL

if [ $INSTALL_PALIB == "yes" ]
then
    download $PALIB_URL
fi

if [ $INSTALL_ULIB == "yes" ]
then
    download $ULIB_URL
fi

if [ $INSTALL_NOCASHGBA == "yes" ]
then
    download $NOCASHGBA_URL
fi

echo
echo >>$LOGFILE
msg "Extracting archives..."

msg " ...devkitARM"
tar xvf $(stripURL $DEVKITARM_URL) -C $DEVKITPRO_PATH >>$LOGFILE
checkForErrors "Problem extracting $(stripURL $DEVKITARM_URL)"


msg " ...libnds"
tar xvf $(stripURL $LIBNDS_URL) -C $LIBNDS_PATH >>$LOGFILE
checkForErrors "Problem extracting $(stripURL $LIBNDS_URL)"

msg " ...maxmod"
tar xvf $(stripURL $MAXMOD_URL) -C $MAXMOD_PATH >>$LOGFILE
checkForErrors "Problem extracting $(stripURL $MAXMOD_URL)"

msg " ...default arm7"
tar xvf $(stripURL $DEFAULT_ARM7_URL) -C $DEFAULT_ARM7_PATH >>$LOGFILE
checkForErrors "Problem extracting $(stripURL $DEFAULT_ARM7_URL)"

msg " ...libnds_examples"
tar xvf $(stripURL $LIBNDS_EX_URL) -C $LIBNDS_EX_PATH >>$LOGFILE
checkForErrors "Problem extracting $(stripURL $LIBNDS_EX_URL)"

msg " ...libfat"
tar xvf $(stripURL $LIBFAT_URL) -C $LIBNDS_PATH >>$LOGFILE
checkForErrors "Problem extracting $(stripURL $LIBFAT_URL)"

msg " ...dswifi"
tar xvf $(stripURL $DSWIFI_URL) -C $LIBNDS_PATH >>$LOGFILE
checkForErrors "Problem extracting $(stripURL $DSWIFI_URL)"


if [ $INSTALL_NOCASHGBA == "yes" ]
then
    msg " ...NO\$GBA"
    unzip -o $(stripURL $NOCASHGBA_URL) -d $NOCASHGBA_PATH >>$LOGFILE
    checkForErrors "Problem extracting $(stripURL $NOCASHGBA_URL)"
fi

if [ $INSTALL_PALIB == "yes" ]
then
    msg " ...PAlib"
    7zr x  -o$PALIB_PATH -y $(stripURL $PALIB_URL) >>$LOGFILE
    checkForErrors "Problem extracting $(stripURL $PALIB_URL)"
    msg " ...Applying some fixes to PAlib"
    sed -i 's/\.\.\\PA_BgStruct.h/..\/PA_BgStruct.h/' $PALIB_PATH/include/nds/arm9/PA_BgTiles.h
    sed -i 's/echo\./echo ./' $PALIB_PATH/lib/PA_Makefile
    msg " ...rebuilding PAlib"
    pushd $PALIB_PATH/source
    make clean
    make
    checkForErrors "Issues rebuilding PAlib"
    popd >>$LOGFILE
fi

if [ $INSTALL_ULIB == "yes" ]
then
    msg " ...uLibrary"
    7zr x  -o$ULIB_PATH -y $(stripURL $ULIB_URL) >>$LOGFILE
    checkForErrors "Problem extracting $(stripURL $ULIB_URL)"
    createDir $ULIB_INC_PATH
    createDir $ULIB_LIB_PATH
    msg " ....moving some files around"
    cp $ULIB_PATH/uLibrary/Install/*h $ULIB_INC_PATH/. >>$LOGFILE
    checkForErrors "Problem copying some files (see logfile)"
    cp $ULIB_PATH/uLibrary/Install/*a $ULIB_LIB_PATH/. >>$LOGFILE
    checkForErrors "Problem copying some files (see logfile)"

    msg " ...rebuilding uLibrary"
    pushd $ULIB_PATH/uLibrary/Source
    make clean
    make
    checkForErrors "Issues rebuilding uLibrary"
    popd >>$LOGFILE
fi

popd >>$LOGFILE

echo
msg "devkitPRO installed successfully!"
msg
msg "One last step: add (or update) the following lines in $HOME/.bashrc:"
echo "export DEVKITPRO=$DEVKITPRO_PATH"
echo "export DEVKITARM=\$DEVKITPRO/devkitARM"
if [ $INSTALL_PALIB == "yes" ]
then
    echo "export PAPATH=\$DEVKITPRO/PAlib/lib"
fi
if [ $INSTALL_NOCASHGBA == "yes" ]
then
    echo "export NOCASHGBA=$NOCASHGBA_PATH_PRINT"
    # Yes, that's seven backslashes in a row:
    echo "alias nds=\"wine \$NOCASHGBA/NO\\\\\\\$GBA.EXE\""
fi
echo
