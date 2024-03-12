#!/bin/bash -x

grep '[S]SID\|[K]EY' $0 && exit

IMG=lede-imagebuilder-17.01.7-brcm47xx-legacy.Linux-x86_64
SDK=lede-sdk-17.01.7-brcm47xx-legacy_gcc-5.4.0_musl-1.1.16.Linux-x86_64
URL=https://downloads.openwrt.org/releases/17.01.7/targets/brcm47xx/legacy
mkdir -p ~/lede
cd ~/lede
[ -e $IMG.tar.xz ] || wget $URL/$IMG.tar.xz || exit
[ -e $SDK.tar.xz ] || wget $URL/$SDK.tar.xz || exit
rm -fr k/
mkdir k/
cd k/
tar -Jxf ../$IMG.tar.xz
tar -Jxf ../$SDK.tar.xz
cd $SDK/
ctangle ~/time/time-write.w || exit
STAGING_DIR=~/lede/k/$SDK/staging_dir/toolchain* ./staging_dir/toolchain*/bin/mipsel-openwrt-linux-gcc time-write.c -o time-write || exit
cd ../$IMG/
mkdir -p files/etc/uci-defaults/
cat <<'EOF' >files/etc/uci-defaults/my
uci set network.lan.ipaddr=192.168.1.2
uci del network.lan.ifname
uci del network.lan.type
uci commit network
uci set wireless.radio0.disabled=0
uci set wireless.radio0.txpower=3
uci set wireless.default_radio0.mode=sta
uci set wireless.default_radio0.ssid=SSID
uci set wireless.default_radio0.encryption=psk2
uci set wireless.default_radio0.key=KEY
uci commit wireless
uci set dhcp.lan.ignore=1
uci commit dhcp
uci set system.@system[0].timezone=GMT-7
uci set system.ntp.server=192.168.1.1 # address of raspberry (gps)
uci commit system
EOF

mkdir -p files/bin/
cp ../$SDK/time-write files/bin/

mkdir -p files/etc/
cat <<'EOF' >files/etc/rc.local
time-write &
cat <<'FOE' | sh &
sleep 60
while [ 1 ]; do
  ### uncomment this manually after you flash the router
  # ping -c1 `uci get system.ntp.server` >/dev/null || reboot # to reconnect wifi automatically
  sleep 5
done
FOE
exit 0
EOF

mkdir -p files/etc/crontabs/
cat <<'EOF' >files/etc/crontabs/root
0 0 * * * stty -F /dev/ttyACM0 50
0 21 * * * stty -F /dev/ttyACM0 75
0 3 * * * stty -F /dev/ttyACM0 75
0 4 * * * stty -F /dev/ttyACM0 110
0 7 * * 1-5 stty -F /dev/ttyACM0 50
0 16 * * 1-5 stty -F /dev/ttyACM0 110
EOF

make image PROFILE=Broadcom-b43 PACKAGES="kmod-usb-ohci kmod-usb-acm coreutils-stty" FILES=files/
{ RET=$?; } 2>/dev/null
{ set +x; } 2>/dev/null
if [ $RET = 0 ]; then
  ls ~/lede/k/*-imagebuilder-*/bin/*/*/*/*-standard-squashfs.trx # mtd -r write /tmp/fw.img firmware
fi
