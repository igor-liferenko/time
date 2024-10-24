#!/bin/bash -x

[ $# = 3 ] || exit

IMG=lede-imagebuilder-17.01.7-brcm47xx-legacy.Linux-x86_64
SDK=lede-sdk-17.01.7-brcm47xx-legacy_gcc-5.4.0_musl-1.1.16.Linux-x86_64
URL=https://downloads.openwrt.org/releases/17.01.7/targets/brcm47xx/legacy
mkdir -p ~/lede
cd ~/lede
[ -e $IMG.tar.xz ] || wget $URL/$IMG.tar.xz || exit
[ -e $SDK.tar.xz ] || wget $URL/$SDK.tar.xz || exit
rm -fr dir320/
mkdir dir320/
cd dir320/
tar -Jxf ../$IMG.tar.xz
tar -Jxf ../$SDK.tar.xz
cd $SDK/
ctangle ~/time/time-write.w || exit
STAGING_DIR=~/lede/dir320/$SDK/staging_dir/toolchain* ./staging_dir/toolchain*/bin/mipsel-openwrt-linux-gcc time-write.c -o time-write || exit
cd ../$IMG/
mkdir -p files/etc/uci-defaults/
cat <<'EOF' >files/etc/uci-defaults/my
uci del network.lan.ifname
uci del network.lan.type
uci set network.lan.proto=dhcp
uci del network.lan.ipaddr
uci del network.lan.netmask
uci commit network
uci set wireless.radio0.disabled=0
uci set wireless.radio0.txpower=TXPOWER
uci set wireless.default_radio0.mode=sta
uci set wireless.default_radio0.ssid=SSID
uci set wireless.default_radio0.encryption=psk2
uci set wireless.default_radio0.key=KEY
uci commit wireless
uci set dhcp.lan.ignore=1
uci commit dhcp
uci set system.@system[0].timezone=GMT-7
uci commit system
EOF
sed -i s/SSID/$1/ files/etc/uci-defaults/my
sed -i s/KEY/$2/ files/etc/uci-defaults/my
sed -i s/TXPOWER/$3/ files/etc/uci-defaults/my # same as txpower of corresponding access point

mkdir -p files/bin/
cp ../$SDK/time-write files/bin/

mkdir -p files/etc/
cat <<'EOF' >files/etc/rc.local
time-write &
exit 0
EOF

make image PROFILE=Broadcom-b43 PACKAGES="kmod-usb-ohci kmod-usb-acm coreutils-stty" FILES=files/
{ RET=$?; } 2>/dev/null
{ set +x; } 2>/dev/null
if [ $RET = 0 ]; then
  ls ~/lede/dir320/*-imagebuilder-*/bin/*/*/*/*-standard-squashfs.trx # mtd -r write /tmp/fw.img firmware
fi
