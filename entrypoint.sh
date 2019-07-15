#!/bin/sh
set -e

set_ip () {
  sleep 5
  for i in `seq 10`; do
    sleep 1

    if ip tap | grep -q vpn_${CLIENT_NICNAME}; then
      IP=$(ip -f inet -o a show vpn_${CLIENT_NICNAME} | awk '{print $4}')
      if [ -n "${IP}" ]; then break; fi

      if [ -n "${CLIENT_IP}" ]; then
        ip a add ${CLIENT_IP} dev vpn_${CLIENT_NICNAME}
        if [ $? -eq 0 ]; then
          echo "succeed: set ip: ${CLIENT_IP}"
        else
          echo "failed: set ip: ${CLIENT_IP}"
        fi
        return 0
      else
        dhclient vpn_${CLIENT_NICNAME}
        sleep1
        IP=$(ip -f inet -o a show vpn_${CLIENT_NICNAME} | awk '{print $4}')
        if [ -n "${IP}" ]; then
          echo "succeed: set ip: ${IP}"
        else
          echo "failed: set ip: ${IP}"
        fi
        return 0
      fi
      break
    fi
  done
  echo "not set ip"
}

case "$1" in
  "client")
    set_ip &
    echo "start vpnclient"
    exec sh -c "/root/vpnclient execsvc"
    ;;
  "server")
    echo "start vpnserver"
    exec sh -c "/root/vpnserver execsvc"
    ;;
esac
exec sh -c "`echo $@`"