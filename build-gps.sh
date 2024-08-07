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
uci set gpsd.core.device=/dev/ttyACM0 # to see if it works, use `gpspipe -r'
uci commit gpsd
# ===== ntpd config is generated dynamically by /etc/init.d/ntpd =====
# ========== therefore we do not change the config directly ==========
uci set system.ntp.enable_server=1 # to make $enable_server non-zero in /etc/init.d/ntpd
# -restrict -4 default noserve
# -restrict -6 default noserve
# +restrict default limited kod nomodify notrap nopeer
# +restrict -6 default limited kod nomodify notrap nopeer
uci del system.ntp.server # to make $server empty in /etc/init.d/ntpd
# -server 0.openwrt.pool.ntp.org iburst
# -server 1.openwrt.pool.ntp.org iburst
# -server 2.openwrt.pool.ntp.org iburst
# -server 3.openwrt.pool.ntp.org iburst
sed -i '/for i in $server/i\
emit "server 127.127.28.0"\
emit "fudge 127.127.28.0 flag1 1"' /etc/init.d/ntpd
# +server 127.127.28.0
# +fudge 127.127.28.0 flag1 1
# NOTE: the fudge setting is needed in order that system time is set to gps time
#       no matter how big is the gap between these two time stamps
# TODO: instead of previous two commands ('uci del...' and 'sed...') try
# uci set system.ntp.server=127.127.28.0
# =======================================================================
uci set system.@system[0].timezone=GMT-7
uci commit system
echo 5c:d9:98:1b:81:27 192.168.1.2 >>/etc/ethers
echo f0:7d:68:83:16:eb 192.168.1.3 >>/etc/ethers
EOF
sed -i s/SSID/$1/ files/etc/uci-defaults/my
sed -i s/KEY/$2/ files/etc/uci-defaults/my

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
#
*/10 * * * * check-dir320
EOF

mkdir -p files/bin/
cat <<'EOF' >files/bin/check-dir320
#!/bin/sh
# Setting ntp server address to gps cannot be done in build-dir320.sh (it is universal).
# Setting ntp server address via dhcp does not work.
# Therefore just warn if it is not set.
# To set it, run the following on each blinking device:
#   uci set system.ntp.server=192.168.1.1
#   uci commit system
#   reboot
for i in `cat /etc/ethers | cut -d' ' -f2`; do
  ssh -y $i '[ "$(uci get system.ntp.server)" = 192.168.1.1 ] && exit; mkdir /tmp/blink || exit; sh -c "speed=50; while [ 1 ]; do stty -F /dev/ttyACM0 \$speed; sleep 1; [ \$speed = 50 ] && speed=110 || speed=50; done" &'
done
EOF
chmod +x files/bin/check-dir320

make image PROFILE=tplink_tl-wr842n-v5 PACKAGES="gpsd-clients gpsd ntpd kmod-usb-acm" FILES=files/
{ RET=$?; } 2>/dev/null
{ set +x; } 2>/dev/null
if [ $RET = 0 ]; then
  ls ~/openwrt/gps/*/bin/*/*/*/*-sysupgrade.bin # mtd -r write /tmp/fw.img firmware
fi
