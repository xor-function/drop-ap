#!/bin/sh
#
# create-dropAP.sh
# a short shell script to simplify the proccess of converting a
# openwrt installation to serve as a disposable access point
# with the sole purpose of aiding the distribution of information.
# in a SneakerNet like fasion. Potientially this can be used
# to create a type of airgap.
#
#
# xor-function
# nightowlconsulting.com


tstamp() {
date +"%F"_"%H":"%M"
}

# func requires aguments (full path/file name) and tstamp() func ****
make_runlog() {
   touch $1
   printf "\nscript run on\n"$(tstamp)"\n" > $1
}

# func gets path and loads it to spath variable
get_path() {
spath="$( cd "$(dirname "$0")" ; pwd -P )"
if [[ ! -e  $spath/README ]]; then
      printf "the README was not found.\nDid you copy it as well? \ncannot continue\nexiting.."
      exit
fi
}

get_permission() {
 while true; do
       read ansr
       case $ansr in
            [Yy] ) break;;
            [Nn] ) printf "\nexiting...\n"; exit;;
               * ) printf "\nplease answer y or n";;
       esac
 done

 printf "\ncontinuing...\n"
}


printf "\n\n!!!-*-*-*-WARNING-*-*-*-WARNING-*-*-*-WARNING-*-*-*-!!!\n"
printf "\nTHIS SCRIPT WAS MADE DEVD IN THE MR3020 \nUSE IN OTHER PLATFORMS AT YOUR OWN RISK!!!"
printf "\nADMIN BY SHELL (SSH/SERIAL) OR NOTHING AS LUCI WILL BE WIPED....\n"
printf "\nDue to the size of the flash on this device\nThe splash page will need to use the /www folder were luci resides"
printf "\nuhttpd will be changed to run on port 80."
printf "\nscript will write to /www/, /etc/config/, /etc/dnsmasq.conf"
printf "\nThe default page provided is a template, you will need to add content.\n"
printf "\nwireless IP 10.0.1.1/24\nethernet IP Will listen for DHCP to issue an IP to it."
printf "\nNetworks will be isolated by NAT.\n"
printf "\nAll dns request's will resolve to the IP of this device\nDirecting all HTTP traffic to Openwrt's webserver"
printf "\nit will not function as a normal AP as it will not provided Internet access"
printf "\neven if connected. All/Any files will need to be stored on this device.\n"
printf "\nAfter runing script and restarting device when you connect the"
printf "\nethernet port to another network you may have conflicting DNS servers."
printf "\nCONTINUE? (y/n)\n"

get_permission

rm -rf /www/*
cat > /www/index.html << EOL
<html><body><h1>DropAP works...</h1>
<p>This is the default web page.</p>
<p>The web server software is running but no content is avaliable... yet.</p>
<p>Make a simple html web page for hosting files, however the space is limited.</p>
<p>It may be best to use this for public key exchange or distributing .onion site info. </p>
<p>For hosting large files you will need to add external storage along with installing the nessary packages.</p>
<big style="font-weight: bold;"><big><a href="/README" target="_blank">Here is the README..</a>
</body></html>
EOL

get_path
cp $spath/README /www/

tail -n 79 /etc/config/uhttpd > /tmp/uhttpd-tmp
cat > /etc/config/uhttpd << EOL
# Server configuration
config uhttpd main

        # HTTP listen addresses, multiple allowed
        list listen_http        0.0.0.0:80
#       list listen_http        [::]:80

        # HTTPS listen addresses, multiple allowed
        list listen_https       0.0.0.0:443
#       list listen_https       [::]:443

        # Redirect users to index.html
        option error_page /
EOL
cat /tmp/uhttpd-tmp >> /etc/config/uhttpd

# turning off ssh access to device from wireless lan
cat > /etc/config/dropbear << EOL
config dropbear
        option PasswordAuth 'on'
        option Port '22'
        option Interface 'lan'

config dropbear
        option Port '22'
        option PasswordAuth 'on'

EOL


cat > /etc/config/dhcp << EOL
config dnsmasq
        option domainneeded     1
        option boguspriv        1
        option filterwin2k      0  # enable for dial on demand
        option localise_queries 1
        option rebind_protection 1  # disable if upstream must serve RFC1918 addresses
        option rebind_localhost 1  # enable for RBL checking and similar services
        option local    '/lan/'
        option domain   'lan'
        option expandhosts      1
        option nonegcache       0
        option authoritative    1
        option readethers       1
        option leasefile        '/tmp/dhcp.leases'
        option resolvfile       '/tmp/resolv.conf.auto'

config dhcp lan
        option interface        lan
        option ignore   1

config dhcp wlan
        option interface        wlan
        option start    100
        option limit    150
        option leasetime        12h

EOL

cat > /etc/config/network << EOL
config interface 'loopback'
        option ifname 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config interface 'lan'
        option ifname 'eth0'
        option proto 'dhcp'

config interface 'wlan'
        option ifname 'wlan0'
        option proto 'static'
        option ipaddr '10.0.1.1'
        option netmask '255.255.255.0'

EOL


# geting the wlan mac
mac=$(cat /sys/class/net/eth0/address)

cat > /etc/config/wireless << EOL
config wifi-device  radio0
        option type     mac80211
        option channel  11
        option macaddr  $mac
	option hwmode	11ng
	option htmode	HT20
	list ht_capab	SHORT-GI-20
	list ht_capab	SHORT-GI-40
	list ht_capab	RX-STBC1
	list ht_capab	DSSS_CCK-40
        # TO ENABLE WIFI CHANGE TO 0 | To DISABLE WIFI CHANGE TO 1
        option disabled 0

config wifi-iface
        option device   radio0
        option network  wlan
        option mode     ap
        option ssid     Drop-Ap
        option encryption none
        # option encryption psk2
        # option key soupnazi

EOL

cat > /etc/config/firewall << EOL
config defaults
        option syn_flood        1
        option input            ACCEPT
        option output           ACCEPT
        option forward          REJECT
# Uncomment this line to disable ipv6 rules
        option disable_ipv6     1

config zone
        option name             lan
        option network          'lan'
        option input            ACCEPT
        option output           ACCEPT
        option forward          REJECT
        option masq             1

config zone
        option name             wlan
        option network          'wlan'
        option input            ACCEPT
        option output           ACCEPT
        option forward          REJECT
        option masq             1
        option mtu_fix          1

config forwarding
        option src              lan
        option dest             wlan

config forwarding
        option src              wlan
        option dest             lan

# We need to accept udp packets on port 68,
# see https://dev.openwrt.org/ticket/4108
config rule
        option name             Allow-DHCP-Renew
        option src              wlan
        option proto            udp
        option dest_port        68
        option target           ACCEPT
        option family           ipv4

# Allow IPv4 ping
config rule
        option name             Allow-Ping
        option src              wlan
        option proto            icmp
        option icmp_type        echo-request
        option family           ipv4
        option target           ACCEPT

EOL

cat /etc/dnsmasq.conf > /etc/dnsmasq.bkup
echo "address=/#/10.0.1.1" > /etc/dnsmasq.conf

printf "\nDevice will reboot in 5 seconds....\n\n"
sleep 5
reboot


exit
