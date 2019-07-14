NICNAME=${CLIENT_NICNAME}
# いい感じに変数を変える
ACCOUNT=hoge
VPN_SERVER=hoge.fuga.com:5432
HUB_NAME=VPN
VPN_USERNAME=a
VPN_PASSWORD=12345abc

cat << EOF > commands.txt
NicCreate ${NICNAME}
AccountCreate ${ACCOUNT} /SERVER:${VPN_SERVER} /HUB:${HUB_NAME} /USERNAME:${VPN_USERNAME} /NICNAME:${NICNAME}
AccountPasswordSet ${ACCOUNT} /PASSWORD:${VPN_PASSWORD} /TYPE:standard
AccountStartupSet ${ACCOUNT}
AccountConnect ${ACCOUNT}
EOF

/root/vpncmd localhost /CLIENT /IN:commands.txt
sleep 5
dhclient vpn_${NICNAME}
rm commands.txt init.sh