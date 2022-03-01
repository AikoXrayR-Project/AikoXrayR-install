# XRayR
Một khung phụ trợ Xray có thể dễ dàng hỗ trợ nhiều bảng.

Một khung công tác back-end dựa trên Xray, hỗ trợ các giao thức V2ay, Trojan, Shadowsocks, cực kỳ dễ dàng mở rộng và hỗ trợ kết nối nhiều bảng điều khiển

Tìm mã nguồn tại đây: [XrayR-project/XrayR](https://github.com/AikoCute/XrayR)

Có góp ý gì với mình thì vui lòng liên hệ mình qua 2 hình thức sau để mình cải tiến và cập nhật nhé 

[![](https://img.shields.io/badge/ZaloChat-@AikoCuteZalo-blue.svg)](https://zalo.me/0368629364)
[![](https://img.shields.io/badge/TeleChat-@AikocuteTele-blue.svg)](https://t.me/AikoCute_Player)

## Hướng dẫn chi tiết
[Hướng dẫn](https://xrayr.aikocute.com)
# Một cài đặt chính < Cách 1 >
```
bash <(curl -Ls https://raw.githubusercontent.com/AikoCute/XrayR-release/main/install.sh)
```
# Cài đặt Docker < Cách 2 >

```
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
systemctl start docker
systemctl enable docker
```

# Cài đặt Docker-compile
0. Cài Đặt docker-compose: 
```
curl -fsSL https://get.docker.com | bash -s docker
curl -L "https://github.com/docker/compose/releases/download/1.26.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```
1. tải XrayR về VPS để cài đặt
 ```
 git clone https://github.com/AikoCute/XrayR-release
 ```
2. Truy cập vào thư mục vừa tải
 ```
 cd XrayR-release
 ```
3. Chỉnh sửa cấu hình.
Định dạng cơ bản của tệp cấu hình như sau. Nhiều bảng và nhiều thông tin cấu hình nút có thể được thêm vào cùng một lúc trong Nodes, chỉ cần thêm các mục Nodes ở cùng một định dạng.
4. bắt đầu docker： 
```
docker-compose up -d
```

## Nâng cấp soạn thư Docker
Thực thi trong thư mục docker-compo.yml：
```
docker-compose pull
docker-compose up -d
```


## Cấu hình xrayr

1: dòng `ApiHost` : Link web ví dụ `https://aikocute.com/`

2: dòng `ApiKey` : key của web (lấy trên web admin)

3: dòng `NodeID` : `ID` server (tự đặt)

4: dòng `PanelType` : ví dụ `V2board`, `SSpanel`,... (chữ đầu viết hoa)

5: dòng `devicelimit` : `SL` nhập số người mà bạn muốn sever chạy tối đa

```
Mình đã fix lỗi zalo sẵn trên docker server nên không cần làm gì nữa nhé
```

# XrayR
File Config Của XrayR cho sever Việt Nam < AikoCuteHotMe>
```
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
      NodeID: 1
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
```
## biết ơn: 

1. Tập lệnh này được sửa đổi và thêm các chức năng dựa trên tập lệnh ghép nối rico của @Aiko
2. Nhóm dự án XrayR

## Giới thiệu

Tập lệnh gắn một cú nhấp chuột của trình docker phụ trợ XrayR

> Địa chỉ dự án và tài liệu trợ giúp:  https://github.com/AikoCute/XrayR-release
>
> Địa chỉ dự án XrayR: https://github.com/AikoCute/XrayR
>
> Hướng dẫn chi tiết : https://github.com/AikoCute/XrayR-doc

* Để mở nhiều phần mềm phụ trợ, bạn chỉ cần tạo một thư mục mới và tải tập lệnh xuống thư mục này để chạy



