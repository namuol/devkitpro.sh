#!/bin/bash

# Edit the following properties to your own taste:
#  NOTE: DIRECTORY PATHS MUST BE ABSOLUTE
DEVKITPRO_PATH=$HOME'/devkitpro'
LIBNDS_PATH=$DEVKITPRO_PATH'/libnds'
LIBNDS_EX_PATH=$LIBNDS_PATH'/examples'
NOCASHGBA_PATH=$DEVKITPRO_PATH'/nocashgba'
PALIB_PATH=$DEVKITPRO_PATH
ULIB_PATH=$DEVKITPRO_PATH
ULIB_INC_PATH=$LIBNDS_PATH'/include/ulib'
ULIB_LIB_PATH=$LIBNDS_PATH'/lib'
DOWNLOAD_CACHE_PATH=$HOME'/.devkitpro_cache'
LOGFILE=$PWD'/install.log'

# File URLS:
if [ `uname -m` == "x86_64" ]
then
  DEVKITARM_URL="http://internap.dl.sourceforge.net/sourceforge/devkitpro/devkitARM_r23-x86_64-linux.tar.bz2"
else
  # Default behavior
  DEVKITARM_URL="http://internap.dl.sourceforge.net/sourceforge/devkitpro/devkitARM_r23-i686-linux.tar.bz2"
fi
PALIB_URL="http://palib.info/downloads/Beta/PALib_CommunityUpdate_BETA-080203.7z"
LIBNDS_URL="http://internap.dl.sourceforge.net/sourceforge/devkitpro/libnds-20071023.tar.bz2"
LIBNDS_EX_URL="http://internap.dl.sourceforge.net/sourceforge/devkitpro/nds-examples-20080427.tar.bz2"
LIBFAT_URL="http://internap.dl.sourceforge.net/sourceforge/devkitpro/libfat-nds-20070127.tar.bz2"
DSWIFI_URL="http://internap.dl.sourceforge.net/sourceforge/devkitpro/dswifi-0.3.4.tar.bz2"
NOCASHGBA_URL="http://nocash.emubase.de/no\$gba-w.zip"
ULIB_URL="http://brunni.palib.info/new/dl/nds/uLibrary.rar"

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

createDir $NOCASHGBA_PATH

pushd $DOWNLOAD_CACHE_PATH >>$LOGFILE

echo
echo >>$LOGFILE
msg "Downloading files..."
download $DEVKITARM_URL
download $PALIB_URL
download $LIBNDS_URL
download $LIBNDS_EX_URL
download $ULIB_URL
download $LIBFAT_URL
download $DSWIFI_URL
download $NOCASHGBA_URL

echo
echo >>$LOGFILE
msg "Extracting archives..."

msg " ...devkitARM"
tar xvf $(stripURL $DEVKITARM_URL) -C $DEVKITPRO_PATH >>$LOGFILE
checkForErrors "Problem extracting $(stripURL $DEVKITARM_URL)"

msg " ...PAlib"
7zr x -o$PALIB_PATH -y $(stripURL $PALIB_URL) >>$LOGFILE
checkForErrors "Problem extracting $(stripURL $PALIB_URL)"

msg " ...libnds"
tar xvf $(stripURL $LIBNDS_URL) -C $LIBNDS_PATH >>$LOGFILE
checkForErrors "Problem extracting $(stripURL $LIBNDS_URL)"

msg " ...libnds_examples"
tar xvf $(stripURL $LIBNDS_EX_URL) -C $LIBNDS_EX_PATH >>$LOGFILE
checkForErrors "Problem extracting $(stripURL $LIBNDS_EX_URL)"

msg " ...libfat"
tar xvf $(stripURL $LIBFAT_URL) -C $LIBNDS_PATH >>$LOGFILE
checkForErrors "Problem extracting $(stripURL $LIBFAT_URL)"

msg " ...dswifi"
tar xvf $(stripURL $DSWIFI_URL) -C $LIBNDS_PATH >>$LOGFILE
checkForErrors "Problem extracting $(stripURL $DSWIFI_URL)"

msg " ...NO\$GBA"
unzip -o $(stripURL $NOCASHGBA_URL) -d $NOCASHGBA_PATH >>$LOGFILE
checkForErrors "Problem extracting $(stripURL $NOCASHGBA_URL)"

msg " ...uLibrary"
unrar x $(stripURL $ULIB_URL) $ULIB_PATH >>$LOGFILE
checkForErrors "Problem extracting $(stripURL $ULIB_URL)"
createDir $ULIB_INC_PATH
createDir $ULIB_LIB_PATH
msg " ....moving some files around"
cp $ULIB_PATH/uLibrary/Install/*h $ULIB_INC_PATH/. >>$LOGFILE
checkForErrors "Problem copying some files (see logfile)"
cp $ULIB_PATH/uLibrary/Install/*a $ULIB_LIB_PATH/. >>$LOGFILE
checkForErrors "Problem copying some files (see logfile)"

# For some reason, libnds named their default arm7 binary to 'basic.arm7' even though
#  their example programs expect it to be called 'default.arm7'
# Link it for compatibility:
if [ ! -e "$LIBNDS_PATH/default.arm7" ]
then
    msg "Linking $LIBNDS_PATH/basic.arm7 to $LIBNDS_PATH/default.arm7 for backwards compatibility"
    ln -s $LIBNDS_PATH'/basic.arm7' $LIBNDS_PATH'/default.arm7' >>$LOGFILE
    checkForErrors "Problem linking $NDS_PATH/basic.arm7 to $NDS_PATH/default.arm7"
fi

popd >>$LOGFILE

echo
msg "devkitPRO installed successfully!"
msg
msg "One last step: add/update the following lines in $HOME/.bashrc:"
echo "export DEVKITPRO=$DEVKITPRO_PATH"
echo "export DEVKITARM=\$DEVKITPRO/devkitARM"
echo "export PAPATH=\$DEVKITPRO/PAlib"
echo "alias nds='wine $NOCASHGBA_PATH/NO\\\$GBA.EXE'"
echo
