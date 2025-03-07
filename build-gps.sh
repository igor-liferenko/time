#!/bin/bash -x

[ $# = 2 ] || exit

IMG=openwrt-imagebuilder-18.06.1-ramips-mt76x8.Linux-x86_64
URL=https://downloads.openwrt.org/releases/18.06.1/targets/ramips/mt76x8
mkdir -p ~/openwrt
cd ~/openwrt
[ -e $IMG.tar.xz ] || wget $URL/$IMG.tar.xz || exit
rm -fr gps/
mkdir gps/
cd gps/
tar -Jxf ../$IMG.tar.xz
cd $IMG/
mkdir -p files/etc/uci-defaults/
cat <<'EOF' >files/etc/uci-defaults/my
uci set wireless.radio0.disabled=0
uci set wireless.radio0.txpower=3
uci set wireless.default_radio0.ssid=SSID
uci set wireless.default_radio0.encryption=psk2
uci set wireless.default_radio0.key=KEY
uci commit wireless
uci set gpsd.core.enabled=1
uci set gpsd.core.device=/dev/ttyACM0
uci commit gpsd
uci set system.ntp.enable_server=1
uci set system.ntp.server=127.127.28.0
sed -i '/emit "server $i iburst"/c\
  emit "server $i"\
  emit "fudge $i flag1 1"' /etc/init.d/ntpd
uci set system.@system[0].timezone=GMT-7
uci set system.led_wlan2g.trigger=none # be quiet
uci commit system
echo 5c:d9:98:1b:81:27 192.168.1.2 >>/etc/ethers
echo f0:7d:68:83:16:eb 192.168.1.3 >>/etc/ethers
EOF
sed -i s/SSID/$1/ files/etc/uci-defaults/my
sed -i s/KEY/$2/ files/etc/uci-defaults/my

mkdir -p files/etc/crontabs/
cat <<'EOF' >files/etc/crontabs/root
*/10 * * * * check-dir320
EOF

mkdir -p files/bin/
cat <<'EOF' >files/bin/check-dir320
#!/bin/sh
# Setting ntp server address to gps cannot be done in build-dir320.sh (build-dir320.sh is universal).
# Therefore just warn by blinking if ntp server address is not set to gps.
# To set ntp server address to gps, run the following on each blinking device:
#   uci set system.ntp.server=192.168.1.1
#   uci commit system
#   reboot
for i in `cat /etc/ethers | cut -d' ' -f2`; do
  ssh -y $i '[ "$(uci get system.ntp.server)" = 192.168.1.1 ] && exit; mkdir /tmp/blink || exit; sh -c "speed=50; while [ 1 ]; do stty -F /dev/ttyACM0 \$speed; sleep 1; [ \$speed = 50 ] && speed=110 || speed=50; done" &'
done
EOF
chmod +x files/bin/check-dir320

mkdir -p files/etc/
cat <<'EOF' >files/etc/rc.local
cat <<'FOE' | sh &
# If led is blinking, then the problem is one of the following:
# 1) 'gpspipe -r' exits immediately (the reason of error is printed on terminal)
# 2) output of 'gpspipe -r' is empty (not counting banner)
# 3) output of 'gpspipe -r' does not contain enough data (GPS signal is too weak)
sleep 120
while true; do
  if ntpq -p | grep -q '^*'; then
    echo none >/sys/class/leds/tl-wr842n-v5:amber:wan/trigger
    echo 0 >/sys/class/leds/tl-wr842n-v5:amber:wan/brightness
  else
    echo timer >/sys/class/leds/tl-wr842n-v5:amber:wan/trigger
    echo 100 >/sys/class/leds/tl-wr842n-v5:amber:wan/delay_on
    echo 100 >/sys/class/leds/tl-wr842n-v5:amber:wan/delay_off
  fi
  sleep 60
done
FOE
exit 0
EOF

make image PROFILE=tplink_tl-wr842n-v5 PACKAGES="gpsd-clients gpsd ntpd kmod-usb-acm" FILES=files/ # NOTE: led settings depend on router model
{ RET=$?; } 2>/dev/null
{ set +x; } 2>/dev/null
if [ $RET = 0 ]; then
  ls ~/openwrt/gps/*/bin/*/*/*/*-sysupgrade.bin # mtd -r write /tmp/fw.img firmware
fi
