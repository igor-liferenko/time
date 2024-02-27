#!/bin/bash -x

IMG=openwrt-imagebuilder-23.05.2-bcm27xx-bcm2710.Linux-x86_64
SDK=openwrt-sdk-23.05.2-bcm27xx-bcm2710_gcc-12.3.0_musl.Linux-x86_64
URL=https://downloads.openwrt.org/releases/23.05.2/targets/bcm27xx/bcm2710
mkdir -p ~/openwrt
cd ~/openwrt
[ -e $IMG.tar.xz ] || wget $URL/$IMG.tar.xz || exit
[ -e $SDK.tar.xz ] || wget $URL/$SDK.tar.xz || exit
rm -fr c/
mkdir c/
cd c/
tar -Jxf ../$IMG.tar.xz
tar -Jxf ../$SDK.tar.xz
cd $SDK/
ctangle ~/time/time-write.w || exit
sed -i 's@/dev/ttyACM0@/dev/serial/by-id/usb-03eb_2018-if00@' time-write.c
STAGING_DIR=~/openwrt/c/$SDK/staging_dir/toolchain* ./staging_dir/toolchain*/bin/aarch64-openwrt-linux-gcc time-write.c -o time-write || exit
ctangle ~/time/time-intensity.w || exit
sed -i 's@/dev/ttyACM0@/dev/serial/by-id/usb-03eb_2018-if00@' time-intensity.c
STAGING_DIR=~/openwrt/c/$SDK/staging_dir/toolchain* ./staging_dir/toolchain*/bin/aarch64-openwrt-linux-gcc time-intensity.c -o time-intensity || exit
cd ../$IMG/
mkdir -p files/etc/uci-defaults/
cat <<'EOF' >files/etc/uci-defaults/my
uci set wireless.radio0.disabled=0
uci set wireless.radio0.txpower=3
uci set wireless.default_radio0.ssid=MY_LINK2
uci set wireless.default_radio0.encryption=psk2
uci set wireless.default_radio0.key=mirumirmirumirmir
uci commit wireless
uci set gpsd.core.enabled=1
uci set gpsd.core.device=usb-u-blox_AG_-_www.u-blox.com_u-blox_7_-_GPS_GNSS_Receiver-if00 # to see if it works, use `gpspipe -r'
uci commit gpsd
# NOTE: ntpd.conf is generated dynamically by /etc/init.d/ntpd
sed -i '/for i in $server/i\
emit "server 127.127.28.0"\
emit "fudge 127.127.28.0 flag1 1"' /etc/init.d/ntpd
uci del system.ntp.server # to make $server empty in /etc/init.d/ntpd
uci set system.ntp.enable_server=1 # to make $enable_server non-zero in /etc/init.d/ntpd
uci set system.@system[0].timezone=GMT-7
uci commit system
EOF

mkdir -p files/bin/
cp ../$SDK/time-write files/bin/
cp ../$SDK/time-intensity files/bin/

mkdir -p files/etc/
cat <<'EOF' >files/etc/rc.local
time-write &
exit 0
EOF

mkdir -p files/etc/crontabs/
cat <<'EOF' >files/etc/crontabs/root
0 0 * * * time-intensity off
0 21 * * * time-intensity 0
0 4 * * * time-intensity F
EOF

make image PROFILE=rpi-3 PACKAGES="gpsd-clients gpsd ntpd kmod-usb-acm" FILES=files/
{ RET=$?; } 2>/dev/null
{ set +x; } 2>/dev/null
gunzip bin/*/*/*/*-ext4-factory.img.gz
if [ $RET = 0 ]; then
  echo
  echo 'First umount and then do (changing sdX to proper name):'
  echo '  dd if=`ls ~/openwrt/c/*/bin/*/*/*/*-ext4-factory.img` of=/dev/sdX bs=4M; sync'
fi
