#!/bin/bash
# Build openwrt in docker container

# Enviroment
GIT_BRANCH='openwrt-18.06'
CORES='-j6'
DEBUG='false'

# Stop on error
set -e

## Setup ccache
# Update symlinks
sudo /usr/sbin/update-ccache-symlinks

# Prepend ccache into the PATH
# if [[ -z "${/usr/lib/ccache:$PATH}" ]];
#     then
#         MY_SCRIPT_VARIABLE="Some default value because DEPLOY_ENV is undefined"
#     else
#         MY_SCRIPT_VARIABLE="${DEPLOY_ENV}"
# fi
# echo "printenv PATH" | find /C /I ";</usr/lib/ccache:$PATH>;"

echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc

# Source bashrc to test the new PATH
source ~/.bashrc

# Git clone openwrt openwrt
if [ ! -d openwrt/ ]
    then
        git clone https://git.openwrt.org/openwrt/openwrt.git -b $GIT_BRANCH
        cd openwrt

        ./scripts/feeds update -a
        ./scripts/feeds install -a
    else
        echo "Found openwrt/ directory from previous git clone"
        echo "Skipping..."
        echo "Pulling updates from git and cleaning openwrt/"

        cd openwrt
        rm -rf feeds/*
        rm -rf package/*

        git fetch origin
        git reset --hard origin/$GIT_BRANCH
        git clean -f -d
        git pull

        make distclean

        ./scripts/feeds update -a
        ./scripts/feeds install -a
fi
  
# Setup .config from config.seed and update seed for new changes
# cp ../config.seed ../openwrt/.config
# ./scripts/diffconfig.sh > diffconfig
# # Write changes to .config
# cp diffconfig .config
#make defconfig;make oldconfig
make menuconfig

# Compile
make download

# Make output folders
mkdir -p ../output

if [ $DEBUG=true ]
    then
        time make V=s $CORES 2>&1 | tee ../output/make.log | grep -i error
    else
        time make $CORES
fi

# Cleaning up for git
mkdir -p ../output/$(date +%Y%m%d%H%M)

if [ -f ../output/make.log ]
    then
        mv ../output/make.log ../output/$(date +%Y%m%d%H%M)/make.log
fi

cp .config ../output/$(date +%Y%m%d%H%M)/config.seed.new
cp -R bin/targets/* ../output/$(date +%Y%m%d%H%M)/

echo "Build Success!"

exit 0
