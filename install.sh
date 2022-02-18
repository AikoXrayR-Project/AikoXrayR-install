#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Lỗi：${plain} Tập lệnh này phải được chạy với tư cách người dùng root!\n" && exit 1


echo " ${green}bắt đầu cài đặt docker${plain}"
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

echo " ${green}đã cài đặt docker-compose${plain} "
curl -fsSL https://get.docker.com | bash -s docker
curl -L "https://github.com/docker/compose/releases/download/1.26.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "Cài đặt config file"
aikocute=`cat /dev/urandom | tr -dc '0-9a-z' | head -c 15`
git clone https://github.com/AikoCute/XrayR-release /tmp/$aikocute && cd /tmp/$aikocute
sleep 5s
file="./config.yml"
link="https://aikocute.com/"
docker_compose_file="./docker-compose.yml"
# Điền thông tin vào file config.yml
echo "${green}Nếu không nhập gì thì nó sẽ là ký tự trống${plain}"
read -p "Vui lòng nhập Api Host ：" apihost
echo "----------------------------"
echo "API host của bạn là : $apihost"
echo "----------------------------"
read -p "Vui lòng nhập Api Key："  apikey
echo "----------------------------"
echo "API key của bạn là : $apikey"
echo "----------------------------"
read -p "Vui lòng nhập ID nút：" nodeid
echo "----------------------------"
echo "ID nút của bạn là : $nodeid"
echo "----------------------------"
read -p "Vui lòng nhập PanelType (Panel type: SSpanel, V2board)：" paneltype
echo "----------------------------"
echo "Panel type của bạn là : $paneltype"
echo "----------------------------"
read -p "Giới hạn thiết bị sử dụng :" DeviceLimit
echo "----------------------------"
echo "Giới hạn thiết bị sử dụng của bạn là : $DeviceLimit"
echo "----------------------------"

# ghi thông tin
sed -i "s|$link|$apihost|" $file
sed -i "s|adminadminadminadminadmin|$apikey|" $file
sed -i "s|41|$nodeid|" $file
sed -i "s|V2board|$paneltype|" $file
sed -i "s|0|$DeviceLimit|" $file

echo "Cấu hình hoàn tất"
echo "${green}Khởi động XrayR Docker Compose${plain}" && docker-compose up -d

echo "------------------------------"
echo "${green}XrayR Docker Compose đã khởi động thành công - Bạn có thể sự dụng ngay bây giờ ${plain}"
echo "-------------------------------"
echo "${green}nếu cần cải tiến hay cập nhật thông tin gì vui lòng liên hệ tác giả để góp ý ${plain}"
echo "-------------------------------"
echo "${green} AikoCute ${plain}"
echo "-------------------------------"


 