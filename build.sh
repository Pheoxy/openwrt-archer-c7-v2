#!/bin/bash
# Build an updated Archer C7 V2 Openwrt Image

# Enviroment
BUILDDIR=~/Development/openwrt-archer-c7-v2-builder
MAKECORES=1

# Stop on error
set -e

# Git clone openwrt source
if [ ! -d source/ ]
then
    git clone https://git.openwrt.org/openwrt/openwrt.git source
    cd $BUILDDIR/source
    #cp -r ../files ./
    cp $BUILDDIR/config.seed $BUILDDIR/source/.config

    ./scripts/feeds update -a -f
    ./scripts/feeds install -a
else
    echo "Found source/ directory from previous git clone"
    echo "Skipping..."
    echo "Pulling updates from git and cleaning source/"

    cd $BUILDDIR/source
    rm -rf feeds/*
    rm -rf package/*

    git fetch origin
    git reset --hard origin/master
    git clean -f -d
    git pull

    make clean

    #cp -r ../files ./
    cp $BUILDDIR/config.seed $BUILDDIR/source/.config
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

#mv $BUILDDIR/source/target/linux/generic/backport-4.9/* $BUILDDIR/source/target/linux/generic/pending-4.9/
#rm -rf $BUILDDIR/source/target/linux/generic/patches-4.4

#mv $BUILDDIR/source/target/linux/generic/backport-4.14/* $BUILDDIR/source/target/linux/generic/pending-4.14/
#rm -rf $BUILDDIR/source/target/linux/generic/patches-4.9

# Compile stuff
make menuconfig
make defconfig
make download
make -j$MAKECORES V=s > log.txt

# Cleaning up for git
mkdir -p $BUILDDIR/openwrt-archer-c7-v2
#rm -rf $BUILDDIR/openwrt-archer-c7-v2/files/*
#rm -f $BUILDDIR/openwrt-archer-c7-v2/patches/*
#cp $BUILDDIR/patches/* $BUILDDIR/openwrt-archer-c7-v2/patches/
#cp -r $BUILDDIR/files/* $BUILDDIR/openwrt-archer-c7-v2/files/
cp $BUILDDIR/source/.config $BUILDDIR/openwrt-archer-c7-v2/
cp $BUILDDIR/source/bin/targets/ar71xx/generic/* $BUILDDIR/openwrt-archer-c7-v2/
echo "Copied files to $BUILDDIR/openwrt-archer-c7-v2"
echo "Build Success!"

exit 0
