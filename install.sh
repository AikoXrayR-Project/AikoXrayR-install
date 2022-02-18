#!/bin/bash
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


# ghi thông tin
sed -i "s|$link|$apihost|" $file
sed -i "s|adminadminadminadminadmin|$apikey|" $file
sed -i "s|41|$nodeid|" $file
sed -i "s|V2board|$paneltype|" $file

echo "Cấu hình hoàn tất"
echo "Khởi động XrayR Docker Compose" && docker-compose up -d


 