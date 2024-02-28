#!/bin/sh
wget https://github.com/zhets/noobzvpns/raw/main/github -O /root/.gh
echo ""
echo "###############################################"
echo "## -> NoobzVpn-Server by Noobz-ID Software   ##"
echo "## -> Author : Muhammad Nurkholis            ##"
echo "## -> Email : cholieztzuliz@gmail.com        ##"
echo "## -> Github : https://github.com/noobz-id   ##"
echo "## -> (c) 2017-2024, Noobz-ID Software       ##"
echo "###############################################"
echo "## -> Mod By : Xdxl Store"
echo ""

source /root/.gh
BIN=/usr/bin
CONFIGS=/etc/noobzvpns
SYSTEMD=/etc/systemd/system
SYSTEMCTL=$(which systemctl)
RESOURCES=`$(which dirname) "$0"`
MACHINE=`$(which uname) "-m"`
BINARY_ARCH=""

if [ `id -u` != "0" ]; then
echo "Error at installation, please run installer as root"
exit 1
fi

case $MACHINE in
    "x86_64")
        BINARY_ARCH="noobzvpns.x86_64"
        ;;
    *)
        echo "Error at installation, unsuported cpu-arch $MACHINE"
        exit 1
        ;;
esac

echo "CPU-Arch: $MACHINE, Binary: $BINARY_ARCH"

if [ ! -d $SYSTEMD ]; then
echo "Error at installation, no systemd directory found. make sure your distro using systemd as default init"
exit 1
fi

if [ ! -f $SYSTEMCTL ]; then
echo "Error at installation, no systemctl binary found. make sure your distro using systemd as default init"
exit 1
fi

echo "Preparing upgrade/install..."
if [ -f $SYSTEMD/noobzvpns.service ]; then
$SYSTEMCTL daemon-reload
$SYSTEMCTL stop noobzvpns
$SYSTEMCTL disable noobzvpns
rm $SYSTEMD/noobzvpns.service
fi
if [ -f $BIN/noobzvpns ]; then
rm $BIN/noobzvpns
fi
echo "Copying binary files..."
if [ ! -d $CONFIGS ]; then
mkdir $CONFIGS
fi
if [ -f $CONFIGS/cert.pem ]; then
rm $CONFIGS/cert.pem
fi
if [ -f $CONFIGS/key.pem ]; then
rm $CONFIGS/key.pem
fi

wget ${REPO}/noobzvpns.x86_64 -O $BIN/noobzvpns
wget ${REPO}/cert.pem -O $CONFIGS/cert.pem
wget ${REPO}/key.pem -O $CONFIGS/key.pem

cat > /etc/systemd/system/noobzvpns.service <<-END
[Unit]
Description=NoobzVpn-Server
Wants=network-online.target
After=network.target network-online.target

[Service]
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
User=root
Type=simple
TimeoutStopSec=1
LimitNOFILE=infinity
ExecStart=/usr/bin/noobzvpns --start-service

[Install]
WantedBy=multi-user.target




END

if [ ! -f $CONFIGS/config.json ]; then
cat > $CONFIGS/config.json <<-END
{
	"tcp_std": [
		8880
	],
	"tcp_ssl": [
		8443
	],
	"ssl_cert": "/etc/noobzvpns/cert.pem",
	"ssl_key": "/etc/noobzvpns/key.pem",
	"ssl_version": "AUTO",
	"conn_timeout": 60,
	"dns_resolver": "/etc/resolv.conf",
	"http_ok": "HTTP/1.1 101 Switching Protocols[crlf]Upgrade: websocket[crlf]Connection: Upgrade[crlf][crlf]"
}

END
fi

echo "Setting files permission..."
chmod 700 $BIN/noobzvpns
chmod 600 $CONFIGS/config.json
chmod 600 $SYSTEMD/noobzvpns.service

echo "Finishing upgrade/install..."
$SYSTEMCTL daemon-reload
$SYSTEMCTL enable noobzvpns
$SYSTEMCTL restart noobzvpns

echo "Upgrade/Install NoobzVpn-Server completed."
