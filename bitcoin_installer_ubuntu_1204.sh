#!/bin/bash

#The MIT License (MIT)
#
#Copyright (c) 2014 , "Kay" Umpei Kurokawa
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.


help(){

echo
echo "This is a bash script for obtaining dependencies, downloading, and installing from source"
echo "bitcoind and bitcoin-qt (bitcoin core) on Ubuntu 12.04 ONLY. May or may not work on any "
echo "other platform."
echo
echo "Use -u flag to compile without UPNP support. To specify QT version use -q flag and vesion"
echo "number (only QT4 and QT5 is supported). Default QT version is 4. Bitcoin folder will be"
echo "created on the folder where this script is run from." 
echo
echo "based on instruction :  https://github.com/bitcoin/bitcoin/blob/master/doc/build-unix.md"

}

upnp_compile=1 
qt_compile=4
git_release_version="none"
while getopts "huq:c:" opt; do
    case $opt in
        u)
            echo "Compiling without UPNP Support"
            upnp_compile=0
            ;;
        q) 
            qt_compile=$OPTARG
            if [ $qt_compile -eq 4 ]; then
                echo "Compiling with QT4"
            elif [ $qt_compile -eq 5 ]; then 
                echo "Compiling with QT5"
            else
                echo "QT version only 4 and 5 possible"
                exit 1
            fi
            ;;
        c)
            echo "checking out version: $OPTARG"
            git_release_version=$OPTARG
            ;; 

        h)
            help 
            exit 1 
    esac
done

# Need this to get libdb 4.8 (default in Ubuntu 12.04 is 5.1) 
sudo add-apt-repository ppa:bitcoin/bitcoin
sudo apt-get update

# Install dependencies
sudo apt-get install git-core -y
sudo apt-get install dh-autoreconf -y #needed when running ./autogen.sh
sudo apt-get install build-essential libtool autotools-dev autoconf pkg-config libssl-dev libevent-dev bsdmainutils -y


sudo apt-get install libboost-all-dev
sudo apt-get install libssl-dev -y 
sudo apt-get install libdb4.8-dev -y 
sudo apt-get install libdb4.8++-dev -y 
sudo apt-get install libglib2.0-dev -y
sudo apt-get install libqrencode-dev -y


# Install proper QT version
if [ $qt_compile -eq 4 ]; then
    sudo apt-get install libqt4-dev libprotobuf-dev protobuf-compiler -y 
else
    sudo apt-get install libqt5gui5 libqt5core5 libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev -y
fi

if [ $upnp_compile -eq 1 ] ; then
    sudo apt-get install libminiupnpc-dev -y # optional for UPNPC 
fi 

# Grab from Github
git clone https://github.com/bitcoin/bitcoin.git
if [ "$git_release_version" != "none" ]; then
    (cd bitcoin; git checkout $git_release_version)
fi
# Build
cd bitcoin 
./autogen.sh 
if [ $upnpc_compile -eq 1 ]; then 
    ./configure --without-miniupnpc  
else
    ./configure 
fi 
make
cd .. 
