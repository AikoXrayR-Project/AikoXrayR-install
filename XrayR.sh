#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Lỗi: ${plain} Tập lệnh này phải được chạy với tư cách người dùng root!\n" && exit 1

# check os
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat|rocky|alma|oracle linux"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat|rocky|alma|oracle linux"; then
    release="centos"
else
    echo -e "${red}Phiên bản hệ thống không được phát hiện, vui lòng liên hệ với tác giả kịch bản!${plain}\n" && exit 1
fi

# os version
if [[ -f /etc/os-release ]]; then
    os_version=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [[ -z "$os_version" && -f /etc/lsb-release ]]; then
    os_version=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [[ x"${release}" == x"centos" ]]; then
    if [[ ${os_version} -le 6 ]]; then
        echo -e "${red}Vui lòng sử dụng CentOS 7 trở lên!${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        echo -e "${red}Vui lòng sử dụng Ubuntu 16 hoặc cao hơn!${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red}Vui lòng sử dụng Debian 8 trở lên!${plain}\n" && exit 1
    fi
fi

confirm() {
    if [[ $# > 1 ]]; then
        echo && read -p "$1 [Mặc định$2]: " temp
        if [[ x"${temp}" == x"" ]]; then
            temp=$2
        fi
    else
        read -p "$1 [y/n]: " temp
    fi
    if [[ x"${temp}" == x"y" || x"${temp}" == x"Y" ]]; then
        return 0
    else
        return 1
    fi
}

confirm_restart() {
    confirm "Có khởi động lại AikoXrayR không" "y"
    if [[ $? == 0 ]]; then
        restart
    else
        show_menu
    fi
}

before_show_menu() {
    echo && echo -n -e "${yellow}Nhấn enter để quay lại menu chính: ${plain}" && read temp
    show_menu
}

install() {
    bash <(curl -Ls https://raw.githubusercontents.com/AikoCute/XrayR-release/dev/install.sh)
    if [[ $? == 0 ]]; then
        if [[ $# == 0 ]]; then
            start
        else
            start 0
        fi
    fi
}

update() {
    if [[ $# == 0 ]]; then
        echo && echo -n -e "Nhập phiên bản được chỉ định (phiên bản mới nhất mặc định): " && read version
    else
        version=$2
    fi
    bash <(curl -Ls https://raw.githubusercontents.com/AikoCute/XrayR-release/dev/install.sh) $version
    if [[ $? == 0 ]]; then
        echo -e "${green}Cập nhật hoàn tất, AikoXrayR đã được khởi động lại tự động, vui lòng sử dụng nhật ký XrayR để xem nhật ký chạy${plain}"
        exit
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

config() {
    echo "AikoXrayR sẽ tự động khởi động lại sau khi sửa đổi cấu hình"
    vi /etc/XrayR/config.yml
    sleep 2
    check_status
    case $? in
        0)
            echo -e "Trạng thái AikoXrayR: ${green} Đã được chạy${plain}"
            ;;
        1)
            echo -e "Phát hiện bạn không khởi động AikoXrayR hoặc AikoXrayR không tự khởi động lại được, hãy kiểm tra nhật ký? [Y/n]" && echo
            read -e -p "(Mặc định: y):" yn
            [[ -z ${yn} ]] && yn="y"
            if [[ ${yn} == [Yy] ]]; then
               show_log
            fi
            ;;
        2)
            echo -e "Trạng thái AikoXrayR: ${red} Chưa cài đặt${plain}"
    esac
}

uninstall() {
    confirm "Bạn có chắc chắn muốn gỡ cài đặt AikoXrayR không?" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    systemctl stop XrayR
    systemctl disable XrayR
    rm /etc/systemd/system/XrayR.service -f
    systemctl daemon-reload
    systemctl reset-failed
    rm /etc/XrayR/ -rf
    rm /usr/local/XrayR/ -rf
    rm /usr/bin/XrayR -f

    echo ""
    echo -e "${green} Đã gỡ thành công AikoXrayR hoàn toàn ${plain}"
    echo ""

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

start() {
    check_status
    if [[ $? == 0 ]]; then
        echo ""
        echo -e "${green}AikoXrayR đã chạy rồi, không cần khởi động lại, nếu muốn khởi động lại, vui lòng chọn khởi động lại${plain}"
    else
        systemctl start XrayR
        sleep 2
        check_status
        if [[ $? == 0 ]]; then
            echo -e "${green}AikoXrayR đã khởi động thành công, vui lòng sử dụng nhật ký AikoXrayR để xem nhật ký đang chạy${plain}"
        else
            echo -e "${red}AikoXrayR có thể không khởi động được, vui lòng sử dụng nhật ký AikoXrayR để xem thông tin nhật ký sau này${plain}"
        fi
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

stop() {
    systemctl stop XrayR
    sleep 2
    check_status
    if [[ $? == 1 ]]; then
        echo -e "${green}AikoXrayR đã dừng thành công${plain}"
    else
        echo -e "${red}AikoXrayR không dừng được, có thể do thời gian dừng vượt quá hai giây, vui lòng kiểm tra thông tin nhật ký sau${plain}"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

restart() {
    systemctl restart XrayR
    sleep 2
    check_status
    if [[ $? == 0 ]]; then
        echo -e "${green}AikoXrayR đã khởi động lại thành công, vui lòng sử dụng nhật ký XrayR để xem nhật ký đang chạy${plain}"
    else
        echo -e "${red}AikoXrayR có thể không khởi động được, vui lòng sử dụng nhật ký XrayR để xem thông tin nhật ký sau này${plain}"
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

status() {
    systemctl status XrayR --no-pager -l
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

enable() {
    systemctl enable XrayR
    if [[ $? == 0 ]]; then
        echo -e "${green}AikoXrayR Đặt khởi động để bắt đầu thành công${plain}"
    else
        echo -e "${red}AikoXrayR Không đặt được tự động khởi động khi khởi động${plain}"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

disable() {
    systemctl disable XrayR
    if [[ $? == 0 ]]; then
        echo -e "${green}AikoXrayR Hủy khởi động tự động bắt đầu thành công${plain}"
    else
        echo -e "${red}AikoXrayR Không thể hủy tự động khởi động khởi động${plain}"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

show_log() {
    journalctl -u XrayR.service -e --no-pager -f
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

install_bbr() {
    bash <(curl -L -s https://raw.githubusercontent.com/AikoCute/BBR/aiko/tcp.sh)
}

update_shell() {
    wget -O /usr/bin/XrayR -N --no-check-certificate https://raw.githubusercontents.com/AikoCute/XrayR-release/master/XrayR.sh
    if [[ $? != 0 ]]; then
        echo ""
        echo -e "${red}Không tải được script xuống, vui lòng kiểm tra xem máy có thể kết nối với Github không${plain}"
        before_show_menu
    else
        chmod +x /usr/bin/XrayR
        echo -e "${green}Tập lệnh nâng cấp thành công, vui lòng chạy lại tập lệnh${plain}" && exit 0
    fi
}

# 0: running, 1: not running, 2: not installed
check_status() {
    if [[ ! -f /etc/systemd/system/XrayR.service ]]; then
        return 2
    fi
    temp=$(systemctl status XrayR | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
    if [[ x"${temp}" == x"running" ]]; then
        return 0
    else
        return 1
    fi
}

check_enabled() {
    temp=$(systemctl is-enabled XrayR)
    if [[ x"${temp}" == x"enabled" ]]; then
        return 0
    else
        return 1;
    fi
}

check_uninstall() {
    check_status
    if [[ $? != 2 ]]; then
        echo ""
        echo -e "${red}AikoXrayR đã được cài đặt, vui lòng không cài đặt lại${plain}"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

check_install() {
    check_status
    if [[ $? == 2 ]]; then
        echo ""
        echo -e "${red}Vui lòng cài đặt AikoXrayR trước${plain}"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

show_status() {
    check_status
    case $? in
        0)
            echo -e "Trạng thái AikoXrayR: ${green}Đã được chạy${plain}"
            show_enable_status
            ;;
        1)
            echo -e "Trạng thái AikoXrayR: ${yellow}Không được chạy${plain}"
            show_enable_status
            ;;
        2)
            echo -e "Trạng thái AikoXrayR: ${red}Chưa cài đặt${plain}"
    esac
}

show_enable_status() {
    check_enabled
    if [[ $? == 0 ]]; then
        echo -e "Có tự động bắt đầu không: ${green}CÓ${plain}"
    else
        echo -e "Có tự động bắt đầu không: ${red}Không${plain}"
    fi
}

show_XrayR_version() {
    echo -n "Phiên bản AikoXrayR："
    /usr/local/XrayR/XrayR -version
    echo ""
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

generate_config_file() {
    echo -e "${yellow}AikoXrayR Trình hướng dẫn tạo tệp cấu hình${plain}"
    echo -e "${red}Vui lòng đọc các ghi chú sau:${plain}"
    echo -e "${red}1. Tính năng này hiện đang trong giai đoạn thử nghiệm${plain}"
    echo -e "${red}2. Tệp cấu hình đã tạo sẽ được lưu vào /etc/XrayR/config.yml${plain}"
    echo -e "${red}3. Tệp cấu hình gốc sẽ được lưu vào /etc/XrayR/config.yml.bak${plain}"
    echo -e "${red}4. TLS hiện không được hỗ trợ${plain}"
    read -p "Bạn có muốn tiếp tục tạo các tệp cấu hình không? (y/n)" generate_config_file_continue
    if [[ $generate_config_file_continue =~ "y"|"Y" ]]; then
        echo -e "${yellow}Vui lòng chọn bảng điều khiển sân bay của bạn, nếu không được liệt kê, nó không được hỗ trợ: ${plain}"
        echo -e "${green}1. SSpanel ${plain}"
        echo -e "${green}2. V2board ${plain}"
        echo -e "${green}3. PMpanel ${plain}"
        echo -e "${green}4. Proxypanel ${plain}"
        read -p "Vui lòng nhập PanelType [1-4, mặc định 1]:" PanelType
        case "$PanelType" in
            1 ) PanelType="SSpanel" ;;
            2 ) PanelType="V2board" ;;
            3 ) PanelType="PMpanel" ;;
            4 ) PanelType="Proxypanel" ;;
            * ) PanelType="SSpanel" ;;
        esac
        read -p "Vui lòng nhập APIHost：" ApiHost
        read -p "Vui lòng Apikey：" ApiKey
        read -p "Vui lòng nhập ID nút:" NodeID
        echo -e "${yellow}Vui lòng chọn một giao thức truyền tải nút, nếu không được liệt kê thì nó không được hỗ trợ：${plain}"
        echo -e "${green}1. Shadowsocks ${plain}"
        echo -e "${green}2. Shadowsocks-Plugin ${plain}"
        echo -e "${green}3. V2ray ${plain}"
        echo -e "${green}4. Trojan ${plain}"
        read -p "Vui lòng nhập giao thức của bạn [1-4, mặc định 1]：" NodeType
        case "$NodeType" in
            1 ) NodeType="Shadowsocks" ;;
            2 ) NodeType="Shadowsocks-Plugin" ;;
            3 ) NodeType="V2ray" ;;
            4 ) NodeType="Trojan" ;;
            * ) NodeType="Shadowsocks" ;;
        esac
        cd /etc/XrayR
        mv config.yml config.yml.bak
        cat <<EOF > /etc/XrayR/config.yml
Log:
  Level: warning # Log level: none, error, warning, info, debug 
  AccessPath: # /etc/XrayR/access.Log
  ErrorPath: # /etc/XrayR/error.log
DnsConfigPath: # /etc/XrayR/dns.json # Path to dns config, check https://xtls.github.io/config/base/dns/ for help
InboundConfigPath: # /etc/XrayR/custom_inbound.json # Path to custom inbound config, check https://xtls.github.io/config/inbound.html for help
RouteConfigPath: # /etc/XrayR/route.json # Path to route config, check https://xtls.github.io/config/base/route/ for help
OutboundConfigPath: # /etc/XrayR/custom_outbound.json # Path to custom outbound config, check https://xtls.github.io/config/base/outbound/ for help
ConnetionConfig:
  Handshake: 4 # Handshake time limit, Second
  ConnIdle: 30 # Connection idle time limit, Second
  UplinkOnly: 2 # Time limit when the connection downstream is closed, Second
  DownlinkOnly: 4 # Time limit when the connection is closed after the uplink is closed, Second
  BufferSize: 64 # The internal cache size of each connection, kB 
Nodes:
  -
    PanelType: "$PanelType" # Panel type: SSpanel, V2board, PMpanel, Proxypanel
    ApiConfig:
      ApiHost: "$ApiHost"
      ApiKey: "$ApiKey"
      NodeID: $NodeID
      NodeType: $NodeType # Node type: V2ray, Shadowsocks, Trojan, Shadowsocks-Plugin
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
        echo -e "${green}Tạo tệp cấu hình AikoXrayR hoàn tất, khởi động lại dịch vụ AikoXrayR${plain}"
        xrayr restart
        before_show_menu
    else
        echo -e "${red}Đã hủy tạo hồ sơ AikoXrayR${plain}"
        before_show_menu
    fi
}

# Unlock Port
open_ports() {
    systemctl stop firewalld.service 2>/dev/null
    systemctl disable firewalld.service 2>/dev/null
    setenforce 0 2>/dev/null
    ufw disable 2>/dev/null
    iptables -P INPUT ACCEPT 2>/dev/null
    iptables -P FORWARD ACCEPT 2>/dev/null
    iptables -P OUTPUT ACCEPT 2>/dev/null
    iptables -t nat -F 2>/dev/null
    iptables -t mangle -F 2>/dev/null
    iptables -F 2>/dev/null
    iptables -X 2>/dev/null
    netfilter-persistent save 2>/dev/null
    echo -e "${green}Giải phóng cổng tường lửa thành công!${plain}"
}

show_usage() {
    echo -e ""
    echo "  Cách sử dụng tập lệnh quản lý XrayR     " 
    echo "------------------------------------------"
    echo "           XrayR   - Show admin menu      "
    echo "         AikoXrayR - XrayR by AikoCute    "
    echo "------------------------------------------"
}

show_menu() {
    echo -e "
  ${green}Các tập lệnh quản lý phụ trợ AikoXrayR，${plain}${red} không hoạt động với docker${plain}
--- https://github.com/AikoCute/XrayR ---
  ${green}0.${plain} Settings Config
————————————————
  ${green}1.${plain} Cài đặt AikoXrayR
  ${green}2.${plain} Cập nhật AikoXrayR
  ${green}3.${plain} Gỡ cài đặt AikoXrayR
————————————————
  ${green}4.${plain} Khởi động AikoXrayR
  ${green}5.${plain} Dừng AikoXrayR
  ${green}6.${plain} Khởi động lại AikoXrayR
  ${green}7.${plain} Xem trạng thái AikoXrayR
  ${green}8.${plain} Xem nhật ký AikoXrayR (log)
————————————————
  ${green}9.${plain} Đặt AikoXrayR để bắt đầu tự động
 ${green}10.${plain} Hủy tự động khởi động AikoXrayR
————————————————
 ${green}11.${plain} Một cú nhấp chuột cài đặt bbr (hạt nhân mới nhất)
 ${green}12.${plain} Xem các phiên bản AikoXrayR
 ${green}13.${plain} Nâng cấp tập lệnh bảo trì AikoXrayR
 ${green}14.${plain} Tạo tệp cấu hình AikoXrayR
 ${green}15.${plain} Cho phép tất cả các cổng mạng của VPS
 "
 #Các bản cập nhật tiếp theo có thể được thêm vào chuỗi trên
    show_status
    echo && read -p "Vui lòng nhập một lựa chọn [0-14]: " num

    case "${num}" in
        0) config ;;
        1) check_uninstall && install ;;
        2) check_install && update ;;
        3) check_install && uninstall ;;
        4) check_install && start ;;
        5) check_install && stop ;;
        6) check_install && restart ;;
        7) check_install && status ;;
        8) check_install && show_log ;;
        9) check_install && enable ;;
        10) check_install && disable ;;
        11) install_bbr ;;
        12) check_install && show_XrayR_version ;;
        13) update_shell ;;
        14) generate_config_file ;;
        15) open_ports ;;
        *) echo -e "${red}Vui lòng nhập số chính xác [0-14]${plain}" ;;
    esac
}


if [[ $# > 0 ]]; then
    case $1 in
        "start") check_install 0 && start 0 ;;
        "stop") check_install 0 && stop 0 ;;
        "restart") check_install 0 && restart 0 ;;
        "status") check_install 0 && status 0 ;;
        "enable") check_install 0 && enable 0 ;;
        "disable") check_install 0 && disable 0 ;;
        "log") check_install 0 && show_log 0 ;;
        "update") check_install 0 && update 0 $2 ;;
        "config") config $* ;;
        "generate") generate_config_file ;;
        "install") check_uninstall 0 && install 0 ;;
        "uninstall") check_install 0 && uninstall 0 ;;
        "version") check_install 0 && show_XrayR_version 0 ;;
        "update_shell") update_shell ;;
        *) show_usage
    esac
else
    show_menu
fi
