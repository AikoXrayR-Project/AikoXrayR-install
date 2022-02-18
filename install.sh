#!/bin/bash

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
suijishu=`cat /dev/urandom | tr -dc '0-9a-z' | head -c 15`
git clone https://github.com/AikoCute/XrayR-release /tmp/$suijishu && cd /tmp/$suijishu
sleep 5s
file="./config.yml"
link="https://aikocute.com/"
docker_compose_file="./docker-compose.yml"
# Điền thông tin vào file config.yml
read -p "Vui lòng nhập Api Host ：" apihost
read -p "Vui lòng nhập Api Key："  apikey
read -p "Vui lòng nhập ID nút：" nodeid
read -p "Vui lòng nhập PanelType (Panel type: SSpanel, V2board, PMpanel, Proxypanel)：" paneltype
read -p "Giới hạn thiết bị sử dụng :" DeviceLimit

# ghi thông tin
sed -i "s|$link|$apihost|" $file
sed -i "s|adminadminadminadminadmin|$apikey|" $file
sed -i "s|41|$nodeid|" $file
sed -i "s|V2board|$paneltype|" $file
sed -i "s|0|$DeviceLimit|" $file

echo "Cấu hình hoàn tất"
echo "${green}Khởi động XrayR Docker Compose${plain}" && docker-compose up -d


 