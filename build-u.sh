#!/bin/bash -x

[ $# = 2 ] || exit

IMG=openwrt-imagebuilder-18.06.1-ar71xx-generic.Linux-x86_64
SDK=openwrt-sdk-18.06.1-ar71xx-generic_gcc-7.3.0_musl.Linux-x86_64
URL=https://downloads.openwrt.org/releases/18.06.1/targets/ar71xx/generic
mkdir -p ~/openwrt
cd ~/openwrt
[ -e $IMG.tar.xz ] || wget $URL/$IMG.tar.xz || exit
[ -e $SDK.tar.xz ] || wget $URL/$SDK.tar.xz || exit
rm -fr u/
mkdir u/
cd u/
tar -Jxf ../$IMG.tar.xz
tar -Jxf ../$SDK.tar.xz
cd $SDK/
ctangle ~/time/time-write.w || exit
LC_ALL=C.UTF-8 STAGING_DIR=~/openwrt/u/$SDK/staging_dir/toolchain* ./staging_dir/toolchain*/bin/mips-openwrt-linux-gcc time-write.c -o time-write || exit # LC_ALL=C.UTF-8 is for 18.06.1
cd ../$IMG/
mkdir -p files/etc/uci-defaults/
cat <<'EOF' >files/etc/uci-defaults/my
uci set wireless.radio0.disabled=0
uci set wireless.radio0.txpower=5
uci set wireless.default_radio0.ssid=SSID
uci set wireless.default_radio0.encryption=psk2
uci set wireless.default_radio0.key=KEY
uci commit wireless
uci set system.@system[0].timezone=GMT-7
uci commit system
echo f0:7d:68:82:e1:4e 192.168.1.4 >>/etc/ethers
EOF
sed -i s/SSID/$1/ files/etc/uci-defaults/my
sed -i s/KEY/$2/ files/etc/uci-defaults/my

mkdir -p files/bin/
cp ../$SDK/time-write files/bin/

mkdir -p files/etc/
cat <<'EOF' >files/etc/rc.local
time-write &
exit 0
EOF

make image PROFILE=tl-wr1043nd-v1 PACKAGES="kmod-usb-acm coreutils-stty" FILES=files/
{ RET=$?; } 2>/dev/null
{ set +x; } 2>/dev/null
if [ $RET = 0 ]; then
  ls ~/openwrt/u/*/bin/*/*/*/*-sysupgrade.bin # mtd -r write /tmp/fw.img firmware
fi
