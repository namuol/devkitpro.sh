#!/bin/bash

#
# devkitpro.sh - simple script to set up a devkitARM/libnds/PALib/uLibrary in Linux.
# Maintained by Louis Acresti - louis.acresti@gmail.com - http://lmn.us.to/
# Last URL update: July 28, 2010
#

# Edit the following properties to your own taste:
#  NOTE: DIRECTORY PATHS MUST BE ABSOLUTE
INSTALL_PALIB="yes"
INSTALL_ULIB="yes"
INSTALL_NOCASHGBA="yes"

DEVKITPRO_PATH=$HOME'/devkitpro'
LIBNDS_PATH=$DEVKITPRO_PATH'/libnds'
DEFAULT_ARM7_PATH=$LIBNDS_PATH
LIBNDS_EX_PATH=$LIBNDS_PATH'/examples'
MAXMOD_PATH=$LIBNDS_PATH

NOCASHGBA_PATH="$DEVKITPRO_PATH/nocashgba"
NOCASHGBA_PATH_PRINT="\$DEVKITPRO/nocashgba"

PALIB_PATH=$DEVKITPRO_PATH'/PAlib'

ULIB_PATH=$DEVKITPRO_PATH
ULIB_INC_PATH=$LIBNDS_PATH'/include/ulib'
ULIB_LIB_PATH=$LIBNDS_PATH'/lib'

DOWNLOAD_CACHE_PATH=$HOME'/.devkitpro_cache'
LOGFILE=$PWD'/devkitpro-install.log'

export DEVKITPRO=$DEVKITPRO_PATH
export DEVKITARM=$DEVKITPRO'/devkitARM'
export PAPATH=$DEVKITPRO'/PAlib/lib'

# File URLS:
if [ `uname -m` == "x86_64" ]
then
  DEVKITARM_URL="http://downloads.sourceforge.net/project/devkitpro/devkitARM/devkitARM_r32-x86_64-linux.tar.bz2"
else
  # Default behavior
  DEVKITARM_URL="http://downloads.sourceforge.net/project/devkitpro/devkitARM/devkitARM_r32-i686-linux.tar.bz2"
fi
DEFAULT_ARM7_URL="http://downloads.sourceforge.net/project/devkitpro/default%20arm7/default_arm7-0.5.20.tar.bz2"
PALIB_URL="http://palib-dev.com/PAlib100707.7z"
LIBNDS_URL="http://downloads.sourceforge.net/project/devkitpro/libnds/libnds-1.5.0.tar.bz2"
MAXMOD_URL="http://downloads.sourceforge.net/project/devkitpro/maxmod/maxmod-nds-1.0.6.tar.bz2"
LIBNDS_EX_URL="http://downloads.sourceforge.net/project/devkitpro/examples/nds/nds-examples-20110214.tar.bz2"
LIBFAT_URL="http://downloads.sourceforge.net/project/devkitpro/libfat/libfat-nds-1.0.9.tar.bz2"
LIBFILESYSTEM_URL="http://downloads.sourceforge.net/project/devkitpro/filesystem/libfilesystem-0.9.9.tar.bz2"
DSWIFI_URL="http://downloads.sourceforge.net/project/devkitpro/dswifi/dswifi-0.3.13.tar.bz2"
NOCASHGBA_URL="http://nocash.emubase.de/no\$gba-w.zip"
ULIB_URL="http://brunni.dev-fr.org/dl/nds/uLibrary.7z"

red='\E[31;1m'
green='\E[32;3m'

function msg() {
    echo \-\> $1 >>$LOGFILE
    echo -n -e "$green"
    echo -n \-\>\  
    tput sgr0
    echo $1 >&1
}

function error() {
    echo \-\> ERROR: $1 >>$LOGFILE
    echo -n -e "$red"
    echo -n \-\> ERROR:\  
    tput sgr0
    echo $1 >&2
}

function checkForErrors() {
    ret=$?
    if [ $ret -ne 0 ]
    then
        if [ -n "$1" ]
        then
            error "$@"
        else
            error "Unexpected error: check $LOGFILE for details."
        fi
        exit $ret
    fi
}

function download() {
    if [ ! -e `stripURL $1` ]
    then
        wget -c $1
        checkForErrors "Failed to download file: $1."
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
checkForErrors "The program \"7zr\" is required to run this script. (NOTE: You may want to try installing the 'p7zip' package)"

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
download $LIBFILESYSTEM_URL
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
tmp=$(stripURL $DEVKITARM_URL)
tar xvf $tmp -C $DEVKITPRO_PATH >>$LOGFILE
checkForErrors "Problem extracting $tmp"

msg " ...libnds"
tmp=$(stripURL $LIBNDS_URL)
tar xvf $tmp -C $LIBNDS_PATH >>$LOGFILE
checkForErrors "Problem extracting $tmp"

msg " ...maxmod"
tmp=$(stripURL $MAXMOD_URL)
tar xvf $tmp -C $MAXMOD_PATH >>$LOGFILE
checkForErrors "Problem extracting $tmp"

msg " ...default arm7"
tmp=$(stripURL $DEFAULT_ARM7_URL)
tar xvf $tmp -C $DEFAULT_ARM7_PATH >>$LOGFILE
checkForErrors "Problem extracting $tmp"

msg " ...libnds_examples"
tmp=$(stripURL $LIBNDS_EX_URL)
tar xvf $tmp -C $LIBNDS_EX_PATH >>$LOGFILE
checkForErrors "Problem extracting $tmp"

msg " ...libfat"
tmp=$(stripURL $LIBFAT_URL)
tar xvf $tmp -C $LIBNDS_PATH >>$LOGFILE
checkForErrors "Problem extracting $tmp"

msg " ...libfilesystem"
tmp=$(stripURL $LIBFILESYSTEM_URL)
tar xvf $tmp -C $LIBNDS_PATH >>$LOGFILE
checkForErrors "Problem extracting $tmp"

msg " ...dswifi"
tmp=$(stripURL $DSWIFI_URL)
tar xvf $tmp -C $LIBNDS_PATH >>$LOGFILE
checkForErrors "Problem extracting $tmp"


if [ $INSTALL_NOCASHGBA == "yes" ]
then
    msg " ...NO\$GBA"
    tmp=$(stripURL $NOCASHGBA_URL)
    unzip -o $tmp -d $NOCASHGBA_PATH >>$LOGFILE
    checkForErrors "Problem extracting $tmp"
fi

if [ $INSTALL_PALIB == "yes" ]
then
    msg " ...PAlib"
    tmp=$(stripURL $PALIB_URL)
    7zr x  -o$PALIB_PATH -y $tmp >>$LOGFILE
    checkForErrors "Problem extracting $tmp"
    msg " ...Applying some fixes to PAlib"
    pushd $PALIB_PATH
    mv PAlib/* .
    rmdir PAlib
    popd
    sed -i 's/\.\.\\PA_BgStruct.h/..\/PA_BgStruct.h/' $PALIB_PATH/include/nds/arm9/PA_BgTiles.h
    sed -i 's/echo\./echo ./' $PALIB_PATH/lib/PA_Makefile
    sed -i 's/_user_data\.//' $PALIB_PATH/source/arm9/source/PA_RTC.c
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
    tmp=$(stripURL $ULIB_URL)
    7zr x  -o$ULIB_PATH -y $tmp >>$LOGFILE
    checkForErrors "Problem extracting $tmp"
    createDir $ULIB_INC_PATH
    createDir $ULIB_LIB_PATH

    msg ".....applying a patch"
    
    sed '337i     DynamicArraySet( &glGlob->texturePtrs, glGlob->activeTexture, ulTextureParams[name] );' $ULIB_PATH/uLibrary/Source/texVramManager.c | sed '336d' > $DOWNLOAD_CACHE_PATH/texVramManager.c
    cp $DOWNLOAD_CACHE_PATH/texVramManager.c $ULIB_PATH/uLibrary/Source/texVramManager.c

    msg " ...rebuilding uLibrary"
    pushd $ULIB_PATH/uLibrary/Source
    make clean
    make
    checkForErrors "Issues rebuilding uLibrary"

    msg " ....moving some files around"
    cp $ULIB_PATH/uLibrary/Source/*.h $ULIB_INC_PATH/. >>$LOGFILE
    checkForErrors "Problem copying some files (see logfile)"
    cp $ULIB_PATH/uLibrary/Source/*.a $ULIB_LIB_PATH/. >>$LOGFILE
    checkForErrors "Problem copying some files (see logfile)"

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


