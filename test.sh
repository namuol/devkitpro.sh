#!/bin/bash
#
# test.sh:
#   Compile several example NDS programs to see if our environment is sane.
#

if [ -z $DEVKITPRO ]
then
    export DEVKITPRO=$HOME/devkitpro
    export DEVKITARM=$DEVKITPRO/devkitARM
    export PAPATH=$DEVKITPRO/PAlib/lib
fi

if [ -z $LOGFILE ]
then
    export LOGFILE=devkitpro-test.log
fi

red='\E[31;1m'
green='\E[32;3m'

function error() {
    echo \-\> ERROR: $1 >>$LOGFILE
    echo -n -e "$red"
    echo -n \-\> ERROR:\  
    tput sgr0
    echo $1 >&2
}

function cleanup() {
    rm -rf /tmp/dstrosmash-test
}

function checkForErrors() {
    ret=$?
    if [ $ret -ne 0 ]
    then
        if [ -n "$1" ]
        then
            error "Trouble building $@. See above output for details."
        else
            error "Unexpected error, aborting!"
        fi
        cleanup
        exit $ret
    fi
}

cd $DEVKITPRO/libnds/examples
make clean
make
checkForErrors "libnds Examples"

cd $DEVKITPRO/PAlib/examples/Demos/Frisbee/Frisbee3
make clean
make
checkForErrors "PAlib Examples"

cd $DEVKITPRO/uLibrary/Examples/Example06
make clean
make
checkForErrors "uLibrary Examples"

cd /tmp
git clone git://github.com/namuol/dstrosmash.git dstrosmash-test
cd dstrosmash-test
make clean
make
checkForErrors "DSTROSMASH"
cleanup
