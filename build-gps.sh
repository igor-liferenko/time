#!/bin/bash -x

grep '[S]SID\|[K]EY' $0 && exit

IMG=openwrt-imagebuilder-18.06.4-ramips-mt76x8.Linux-x86_64
URL=https://downloads.openwrt.org/releases/18.06.4/targets/ramips/mt76x8
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
uci set gpsd.core.device=/dev/ttyACM0 # to see if it works, use `gpspipe -r'
uci commit gpsd
# NOTE: ntpd.conf is generated dynamically by /etc/init.d/ntpd
sed -i '/for i in $server/i\
emit "server 127.127.28.0"\
emit "fudge 127.127.28.0 flag1 1"' /etc/init.d/ntpd
uci del system.ntp.server # to make $server empty in /etc/init.d/ntpd
uci set system.ntp.enable_server=1 # to make $enable_server non-zero in /etc/init.d/ntpd
uci set system.@system[0].timezone=GMT-7
uci commit system
echo 5c:d9:98:1b:81:27 192.168.1.2 >>/etc/ethers
#echo MAC 192.168.1.3 >>/etc/ethers
echo 192.168.1.1 0.lede.pool.ntp.org >>/etc/hosts
echo 192.168.1.1 1.lede.pool.ntp.org >>/etc/hosts
echo 192.168.1.1 2.lede.pool.ntp.org >>/etc/hosts
echo 192.168.1.1 3.lede.pool.ntp.org >>/etc/hosts
EOF

mkdir -p files/etc/crontabs/
cat <<'EOF' >files/etc/crontabs/root
0 0 * * * ssh -y 192.168.1.2 stty -F /dev/ttyACM0 50
0 21 * * * ssh -y 192.168.1.2 stty -F /dev/ttyACM0 75
0 3 * * * ssh -y 192.168.1.2 stty -F /dev/ttyACM0 75
0 4 * * * ssh -y 192.168.1.2 stty -F /dev/ttyACM0 110
0 7 * * 1-5 ssh -y 192.168.1.2 stty -F /dev/ttyACM0 50
0 16 * * 1-5 ssh -y 192.168.1.2 stty -F /dev/ttyACM0 110
#
0 0 * * * ssh -y 192.168.1.3 stty -F /dev/ttyACM0 50
0 21 * * * ssh -y 192.168.1.3 stty -F /dev/ttyACM0 75
0 4 * * * ssh -y 192.168.1.3 stty -F /dev/ttyACM0 110
EOF

make image PROFILE=tplink_tl-wr842n-v5 PACKAGES="gpsd-clients gpsd ntpd kmod-usb-acm" FILES=files/
{ RET=$?; } 2>/dev/null
{ set +x; } 2>/dev/null
if [ $RET = 0 ]; then
  ls ~/openwrt/gps/*/bin/*/*/*/*-sysupgrade.bin # mtd -r write /tmp/fw.img firmware
fi
