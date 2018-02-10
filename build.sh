#!/bin/bash
# Build an updated Archer C7 V2 Openwrt Image

# Enviroment
HOMEDIR=~/openwrt-builder
PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl

# Stop on error
set -e

# Git clone openwrt source
if [ ! -d source/ ]
then
    git clone https://github.com/lede-project/source.git
else
    echo "Found source/ directory from previous git clone"
    echo "Skipping..."
    echo "Pulling updates from git"
fi

# Clean
cd $HOMEDIR/source
rm -rf feeds/*
rm -rf package/*
git fetch origin
git reset --hard origin/master
git clean -f -d

# Pull
git pull
make clean
./scripts/feeds update -a -f
./scripts/feeds install -a

# Copy files & configs
cp -r ../files ./
cp $HOMEDIR/config.seed $HOMEDIR/source/.config

# Patch & customize
#for patchfile in `ls ../patches`; do
#    echo "Applying patch: $patchfile"
#    patch -p1 < ../patches/$patchfile
#done

# Remove stuff
rm -f ./feeds/luci/protocols/luci-proto-ppp/luasrc/model/cbi/admin_network/proto_pppoa.lua
rm -f ./feeds/luci/protocols/luci-proto-ipv6/luasrc/model/network/proto_aiccu.lua
rm -f ./feeds/luci/protocols/luci-proto-ipv6/luasrc/model/cbi/admin_network/proto_aiccu.lua
rm -f ./target/linux/ar71xx/base-files/lib/upgrade/dir825.sh
rm -f ./target/linux/ar71xx/base-files/lib/upgrade/allnet.sh
rm -f ./target/linux/ar71xx/base-files/lib/upgrade/merakinand.sh

#mv $HOMEDIR/source/target/linux/generic/backport-4.9/* $HOMEDIR/source/target/linux/generic/pending-4.9/
#rm -rf $HOMEDIR/source/target/linux/generic/patches-4.4

#mv $HOMEDIR/source/target/linux/generic/backport-4.14/* $HOMEDIR/source/target/linux/generic/pending-4.14/
#rm -rf $HOMEDIR/source/target/linux/generic/patches-4.9

# Compile stuff

make defconfig

make -j2 V=s 2>&1 | tee build-fast.log | grep -i '[^_-"a-z]error[^_-.a-z]' 

# Cleaning up for git
mkdir -p $HOMEDIR/openwrt-archer-c7-v2
rm -rf $HOMEDIR/openwrt-archer-c7-v2/files/*
rm -f $HOMEDIR/openwrt-archer-c7-v2/patches/*
cp $HOMEDIR/patches/* $HOMEDIR/openwrt-archer-c7-v2/patches/
cp -r $HOMEDIR/files/* $HOMEDIR/openwrt-archer-c7-v2/files/
cp $HOMEDIR/source/.config $HOMEDIR/openwrt-archer-c7-v2/
cp $HOMEDIR/source/bin/targets/ar71xx/generic/* $HOMEDIR/openwrt-archer-c7-v2/
echo "Copied files to $HOMEDIR/openwrt-archer-c7-v2"
echo "Build Success!"

exit 0
