#!/bin/bash
# Build an updated Archer C7 V2 Openwrt Image

# Enviroment
HOMEDIR=~/openwrt-archer-c7-v2-builder
MAKECORES=3

# Stop on error
set -e

# Git clone openwrt source
if [ ! -d source/ ]
then
    git clone https://git.openwrt.org/openwrt/openwrt.git source
    cd $HOMEDIR/source
    cp -r ../files ./
    cp $HOMEDIR/config.seed $HOMEDIR/source/.config

    ./scripts/feeds update -a -f
    ./scripts/feeds install -a
else
    echo "Found source/ directory from previous git clone"
    echo "Skipping..."
    echo "Pulling updates from git and cleaning source/"

    cd $HOMEDIR/source
    rm -rf feeds/*
    rm -rf package/*

    git fetch origin
    git reset --hard origin/master
    git clean -f -d
    git pull

    make clean

    cp -r ../files ./
    cp $HOMEDIR/config.seed $HOMEDIR/source/.config
    ./scripts/feeds update -a -f
    ./scripts/feeds install -a
fi

# Patch & customize
#for patchfile in `ls ../patches`; do
#    echo "Applying patch: $patchfile"
#    patch -p1 < ../patches/$patchfile
#done

# Remove stuff
#rm -f ./feeds/luci/protocols/luci-proto-ppp/luasrc/model/cbi/admin_network/proto_pppoa.lua
#rm -f ./feeds/luci/protocols/luci-proto-ipv6/luasrc/model/network/proto_aiccu.lua
#rm -f ./feeds/luci/protocols/luci-proto-ipv6/luasrc/model/cbi/admin_network/proto_aiccu.lua
#rm -f ./target/linux/ar71xx/base-files/lib/upgrade/dir825.sh
#rm -f ./target/linux/ar71xx/base-files/lib/upgrade/allnet.sh
#rm -f ./target/linux/ar71xx/base-files/lib/upgrade/merakinand.sh

#mv $HOMEDIR/source/target/linux/generic/backport-4.9/* $HOMEDIR/source/target/linux/generic/pending-4.9/
#rm -rf $HOMEDIR/source/target/linux/generic/patches-4.4

#mv $HOMEDIR/source/target/linux/generic/backport-4.14/* $HOMEDIR/source/target/linux/generic/pending-4.14/
#rm -rf $HOMEDIR/source/target/linux/generic/patches-4.9

# Compile stuff
make menuconfig
make defconfig
make download
make -j$MAKECORES V=s

# Cleaning up for git
mkdir -p $HOMEDIR/openwrt-archer-c7-v2
#rm -rf $HOMEDIR/openwrt-archer-c7-v2/files/*
#rm -f $HOMEDIR/openwrt-archer-c7-v2/patches/*
#cp $HOMEDIR/patches/* $HOMEDIR/openwrt-archer-c7-v2/patches/
#cp -r $HOMEDIR/files/* $HOMEDIR/openwrt-archer-c7-v2/files/
cp $HOMEDIR/source/.config $HOMEDIR/openwrt-archer-c7-v2/
cp $HOMEDIR/source/bin/targets/ar71xx/generic/* $HOMEDIR/openwrt-archer-c7-v2/
echo "Copied files to $HOMEDIR/openwrt-archer-c7-v2"
echo "Build Success!"

exit 0
