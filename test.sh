#!/bin/bash
#
# test.sh:
#   Compile several example NDS programs to see if our environment is sane.
#

if [ -z $DEVKITPRO ]
then
    export DEVKITPRO=/home/louman/devkitpro
    export DEVKITARM=$DEVKITPRO/devkitARM
    export PAPATH=$DEVKITPRO/PAlib/lib
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

function checkForErrors() {
    ret=$?
    if [ $ret -ne 0 ]
    then
        if [ -n "$1" ]
        then
            error "$@"
        else
            error "Unexpected error, aborting!"
        fi
        exit $ret
    fi
}

cd $DEVKITPRO/libnds/examples
make clean
make
checkForErrors "Trouble building libnds examples. See above output for details."

cd $DEVKITPRO/PAlib/examples/Demos/Frisbee/Frisbee3
make clean
make
checkForErrors "Trouble building PAlib examples. See above output for details."

cd $DEVKITPRO/uLibrary/Examples/Example06
make clean
make
checkForErrors "Trouble building uLibrary examples. See above output for details."
