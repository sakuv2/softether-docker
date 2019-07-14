#!/bin/sh
set -e

set_ip () {
  for i in {1..10}; do
    sleep 1
    IP=ip -f inet -o addr show vpn_vpn1 | awk '{print $4}'
    if [ -n "${IP}" ]; then break; fi

    if ip tap | grep --quiet vpn_${CLIENT_NICNAME}; then
      if [ -n "${CLIENT_IP}" ]; then
        ip a add ${CLIENT_IP} dev vpn_${CLIENT_NICNAME}
        if [ $? -ne 0 ]; then
          echo "succeed: set ip: ${CLIENT_IP}"
        else
          echo "failed: set ip: ${CLIENT_IP}"
        fi
      else
        dhclient vpn_${CLIENT_NICNAME}
        IP=ip -f inet -o addr show vpn_vpn1 | awk '{print $4}'
        if [ -n "${IP}" ]; then
          echo "succeed: set ip: ${IP}"
        else
          echo "failed: set ip: ${IP}"
        fi
      fi
      break
    fi
  done
}

case "$1" in
  "client")
    set_ip &
    echo "start vpnclient"
    exec /root/vpnclient execsvc
    ;;
  "server")
    echo "start vpnserver"
    exec /root/vpnserver execsvc
    ;;
esac
exec "$@"