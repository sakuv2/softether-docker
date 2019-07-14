# 変数を自由に変更する
PORT=5432
SERVER_PASSWD=12345abc
HUB_NAME=VPN
HUB_PASSWD=12345abc
USER_NAME=a
USER_PASSWD=a
HOST_IP="10.8.0.254"
HOST_MASK="255.255.255.0"
DHCP_START_IP="10.8.0.11"
DHCP_END_IP="10.8.0.253"
DHCP_MASK="255.255.255.0"
GW=none
DNS=${HOST_IP}

cat << EOF > commands.txt
ServerPasswordSet ${SERVER_PASSWD}
HubDelete DEFAULT

# ユーザー作成
UserCreate ${USER_NAME} /GROUP:none /REALNAME:none /NOTE:none
UserPasswordSet ${USER_NAME} /PASSWORD:${USER_PASSWD}

# 不要なポートを削除する
ListenerDelete 443
ListenerDelete 992
ListenerDelete 1194
ListenerDelete 5555

# 必要なポートを追加する
ListenerCreate ${PORT}

# インターネット接続の維持機能の無効化
KeepDisable

# 不要な方式を停止する
OpenVpnEnable no /PORTS:1194
SstpEnable no

# HUBの設定
# HUBの名前を列挙しない
SetEnumDeny
# SecureNATを使用する
SecureNatHostSet /MAC:none /IP:${HOST_IP} /MASK:${HOST_MASK}
DhcpSet /START:${DHCP_START_IP} /END:${DHCP_END_IP} /MASK:${DHCP_MASK} /EXPIRE:7200 /GW:${GW} /DNS:${DNS} /DNS2:none /DOMAIN:none /LOG:no
SecureNatEnable
EOF

/root/vpncmd /SERVER server /ADMINHUB:DEFAULT /CMD HubCreate ${HUB_NAME} /PASSWORD:${HUB_PASSWD}
/root/vpncmd /SERVER server /ADMINHUB:${HUB_NAME} /IN:commands.txt
rm commands.txt init.sh