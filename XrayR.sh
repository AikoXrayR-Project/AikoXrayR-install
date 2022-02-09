#!/bin/bash

rm -rf $0

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Lỗi：${plain} Tập lệnh này phải được chạy với tư cách người dùng root!\n" && exit 1

pre_install() {
  read -p " ID nút (Node_ID):" node_id
  [ -z "${node_id}" ] && node_id=0
  read -p " Tên miền web : (https://aikocute.com):" api_host
  [ -z "${api_host}" ] && api_host="https://aikocute.com"
  read -p " Apikey (web API):" api_key
  [ -z "${api_key}" ] && api_key="adminadminadminadminadmin"
  echo -e "[1] SSpanel"
  echo -e "[2] V2board"
  read -p "Web đang sử dụng:" panel_num
  if [ "$panel_num" == "1" ]; then
    panel_type="SSpanel"
  elif [ "$panel_num" == "2" ]; then
    panel_type="V2board"
  else
    echo "type error, please try again"
    exit
  fi
  echo -e "[1] V2ray"
  echo -e "[2] Shadowsocks"
  echo -e "[3] Trojan"
  read -p "Loại nút:" node_num
  if [ "$node_num" == "1" ]; then
    node_type="V2ray"
  elif [ "$node_num" == "2" ]; then
    node_type="Shadowsocks"
  elif [ "$node_num" == "3" ]; then
    node_type="Trojan"
  else
    echo "type error, please try again"
    exit
  fi
  echo -e "[1] Có"
  echo -e "[2] Không"
  read -p "Có bật tls / xtls hay không (mặc định không):" is_tls
  if [ "$is_tls" == "1" ]; then
    read -p "Vui lòng nhập tên miền được phân giải cho máy này < cert_domain>:" cert_domain
    echo -e "[1] Có"
    echo -e "[2] Không"
    read -p "Có bật xtls hay không (mặc định không):" is_xtls
    echo -e "[1] Có"
    echo -e "[2] Không"
    read -p "Có bật vless (mặc định không):" is_vless
  fi
}

setting_config () {
    echo "Setting Config"
  cat >config.yml <<EOF
Log:
  Level: none # Log level: none, error, warning, info, debug 
  AccessPath: # /etc/XrayR/access.Log
  ErrorPath: # /etc/XrayR/error.log
DnsConfigPath: # /etc/XrayR/dns.json Path to dns config, check https://xtls.github.io/config/base/dns/ for help
RouteConfigPath: # /etc/XrayR/route.json # Path to route config, check https://xtls.github.io/config/base/route/ for help
OutboundConfigPath: # /etc/XrayR/custom_outbound.json # Path to custom outbound config, check https://xtls.github.io/config/base/outbound/ for help
ConnetionConfig:
  Handshake: 4 # Handshake time limit, Second
  ConnIdle: 10 # Connection idle time limit, Second
  UplinkOnly: 2 # Time limit when the connection downstream is closed, Second
  DownlinkOnly: 4 # Time limit when the connection is closed after the uplink is closed, Second
  BufferSize: 64 # The internal cache size of each connection, kB 
Nodes:
  -
    PanelType: "V2board" # Panel type: SSpanel, V2board, PMpanel, Proxypanel
    ApiConfig:
      ApiHost: "https://aikocute.com"
      ApiKey: "adminadminadminadminadmin"
      NodeID: 41
      NodeType: V2ray # Node type: V2ray, Trojan, Shadowsocks, Shadowsocks-Plugin
      Timeout: 30 # Timeout for the api request
      EnableVless: false # Enable Vless for V2ray Type
      EnableXTLS: false # Enable XTLS for V2ray and Trojan
      SpeedLimit: 0 # Mbps, Local settings will replace remote settings, 0 means disable
      DeviceLimit: 0 # Local settings will replace remote settings, 0 means disable
      RuleListPath: # /etc/XrayR/rulelist Path to local rulelist file
    ControllerConfig:
      ListenIP: 0.0.0.0 # IP address you want to listen
      SendIP: 0.0.0.0 # IP address you want to send pacakage
      UpdatePeriodic: 60 # Time to update the nodeinfo, how many sec.
      EnableDNS: false # Use custom DNS config, Please ensure that you set the dns.json well
      DNSType: AsIs # AsIs, UseIP, UseIPv4, UseIPv6, DNS strategy
      DisableUploadTraffic: false # Disable Upload Traffic to the panel
      DisableGetRule: false # Disable Get Rule from the panel
      DisableIVCheck: false # Disable the anti-reply protection for Shadowsocks
      DisableSniffing: true # Disable domain sniffing 
      EnableProxyProtocol: false # Only works for WebSocket and TCP
      EnableFallback: false # Only support for Trojan and Vless
      FallBackConfigs:  # Support multiple fallbacks
        -
          SNI: # TLS SNI(Server Name Indication), Empty for any
          Path: # HTTP PATH, Empty for any
          Dest: 80 # Required, Destination of fallback, check https://xtls.github.io/config/fallback/ for details.
          ProxyProtocolVer: 0 # Send PROXY protocol version, 0 for dsable
      CertConfig:
        CertMode: dns # Option about how to get certificate: none, file, http, dns. Choose "none" will forcedly disable the tls config.
        CertDomain: "node1.test.com" # Domain to cert
        CertFile: /etc/XrayR/cert/node1.test.com.cert # Provided if the CertMode is file
        KeyFile: /etc/XrayR/cert/node1.test.com.key
        Provider: alidns # DNS cert provider, Get the full support list here: https://go-acme.github.io/lego/dns/
        Email: test@me.com
        DNSEnv: # DNS ENV option used by DNS provider
          ALICLOUD_ACCESS_KEY: aaa
          ALICLOUD_SECRET_KEY: bbb
EOF
  sed -i "s|NodeID:.*|NodeID: ${node_id}|" ./config.yml
  sed -i "s|ApiHost:.*|ApiHost: \"${api_host}\"|" ./config.yml
  sed -i "s|ApiKey:.*|ApiKey: \"${api_key}\"|" ./config.yml
  sed -i "s|PanelType:.*|PanelType: \"${panel_type}\"|" ./config.yml
  sed -i "s|NodeType:.*|NodeType: ${node_type}|" ./config.yml
  if [ "$is_tls" == "1" ]; then
    sed -i "s|CertMode:.*|CertMode: http|" ./config.yml
    sed -i "s|CertDomain:.*|CertDomain: \"${cert_domain}\"|" ./config.yml
  fi
  if [ "$is_xtls" == "1" ]; then
    sed -i "s|EnableXTLS:.*|EnableXTLS: true|" ./config.yml
  fi
  if [ "$is_vless" == "1" ]; then
    sed -i "s|EnableVless:.*|EnableVless: true|" ./config.yml
  fi
}
